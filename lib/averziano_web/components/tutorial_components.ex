defmodule AverzianoWeb.TutorialComponents do
  @moduledoc """
  The "come si gioca" walkthrough: seven steps, each pairing a short
  explanation with a screenshot of the screen it talks about.

  The screenshots are rendered live from `AverzianoWeb.GameComponents` inside a
  phone frame rather than being captured as images, so they keep matching the
  prototypes as the design moves. Card faces stay the neutral placeholders the
  design uses everywhere else.
  """
  use Phoenix.Component

  import AverzianoWeb.GameComponents

  @steps [
    %{
      id: :tavolo,
      title: "Quattro giocatori, due coppie",
      blurb:
        "Mazzo romagnolo da 40 carte, dieci a testa. Il tuo compagno siede di fronte: " <>
          "non potete parlarvi né mostrarvi le carte.",
      notes: ["Tu e il tuo compagno segnate insieme.", "Le carte degli altri restano coperte."]
    },
    %{
      id: :briscola,
      title: "Si battezza la briscola",
      blurb:
        "Chi apre la mano dichiara un seme di briscola prima che si giochi la prima carta. " <>
          "Nessuna discussione, nessun segno: decide da solo.",
      notes: [
        "Il compagno lo scopre insieme agli avversari.",
        "Mano troppo debole? La si manda a monte."
      ]
    },
    %{
      id: :mano,
      title: "Le tue dieci carte",
      blurb:
        "La mano la vedi solo tu. A ventaglio occupa meno spazio, su griglia 2×5 nessuna " <>
          "carta è coperta: cambia solo come le tieni.",
      notes: ["Le carte che non puoi giocare restano sbiadite, non spariscono."]
    },
    %{
      id: :prese,
      title: "Dieci prese, seme obbligato",
      blurb:
        "Chi esce sceglie il seme e gli altri devono rispondere a seme, se ce l'hanno. " <>
          "La presa la vince la briscola più alta, altrimenti la carta più alta del seme di uscita.",
      notes: ["Ordine di forza: 3 · 2 · A · Re · Cavallo · Fante · 7 · 6 · 5 · 4"]
    },
    %{
      id: :dichiarazioni,
      title: "Busso, striscio, volo",
      blurb:
        "L'unico modo per dire qualcosa al compagno. Lo annuncia solo chi apre la presa, " <>
          "una volta sola, e lo sentono anche gli avversari.",
      notes: [
        "Busso — ho forza in questo seme: gioca la tua più alta.",
        "Striscio — me ne restano poche.",
        "Volo — non ne ho più."
      ]
    },
    %{
      id: :marafona,
      title: "La marafona",
      blurb:
        "Asso, 2 e 3 dello stesso seme di briscola in mano. Vale 3 punti, ma dichiararla " <>
          "dice agli avversari esattamente dove stanno tre carte.",
      notes: ["Puoi anche passare e tenerla nascosta."]
    },
    %{
      id: :punti,
      title: "Undici e un terzo per mano",
      blurb:
        "A fine mano si contano i punti delle carte prese. Le frazioni si sommano: quello " <>
          "che avanza sotto il punto non si conta.",
      notes: [
        "Asso — 1 punto",
        "3, 2, Re, Cavallo, Fante — un terzo di punto",
        "Ultima presa — 1 punto",
        "Vince la coppia che arriva a 41."
      ]
    }
  ]

  @trick [
    %{position: "left:50%;top:0;transform:translateX(-50%) rotate(-4deg)"},
    %{position: "left:24px;top:30px;transform:rotate(6deg)"},
    %{position: "right:24px;top:30px;transform:rotate(-7deg)", winning: true}
  ]

  @suits [
    %{name: "Denari", held: "4 carte"},
    %{name: "Coppe", held: "4 · A 2 3"},
    %{name: "Spade", held: "1 carta"},
    %{name: "Bastoni", held: "1 carta"}
  ]

  @doc """
  The walkthrough, in order. Callers index into this list to track progress.
  """
  @spec steps() :: [map()]
  def steps, do: @steps

  @doc """
  The whole walkthrough as a modal: screenshot on one side, words on the other.

  `index` is zero-based into `steps/0`. The caller owns the state, so it passes
  in the event names for the things the stepper can do.
  """
  attr :index, :integer, required: true
  attr :on_close, :string, required: true
  attr :on_prev, :string, required: true
  attr :on_next, :string, required: true
  attr :on_goto, :string, required: true
  attr :on_key, :string, required: true

  @spec tutorial(map()) :: Phoenix.LiveView.Rendered.t()
  def tutorial(assigns) do
    assigns =
      assign(assigns,
        steps: @steps,
        step: Enum.at(@steps, assigns.index),
        total: length(@steps),
        first?: assigns.index == 0,
        last?: assigns.index == length(@steps) - 1
      )

    ~H"""
    <div
      id="tutorial"
      class="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-brand-night/70 p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="tutorial-title"
      phx-window-keydown={@on_key}
    >
      <div class="my-auto w-full max-w-[760px] rounded-3xl bg-white p-6 shadow-[0_24px_60px_rgba(36,28,61,.35)] sm:p-8">
        <div class="flex items-start gap-4">
          <div class="min-w-0 flex-1">
            <p class="font-mono text-[11px] uppercase leading-none tracking-[.1em] text-muted">
              Come si gioca · passo {@index + 1}/{@total}
            </p>
            <h2 id="tutorial-title" class="mt-2 font-display text-[26px] leading-tight">
              {@step.title}
            </h2>
          </div>
          <button
            type="button"
            phx-click={@on_close}
            aria-label="Chiudi il tutorial"
            class="flex-none rounded-full border border-edge px-3 py-1.5 font-mono text-[11px] text-muted hover:border-brand hover:text-brand"
          >
            chiudi
          </button>
        </div>

        <div class="mt-6 grid gap-6 sm:grid-cols-[268px_1fr] sm:items-start">
          <.screenshot step={@step.id} />

          <div>
            <p class="text-[15px] leading-relaxed text-prose">{@step.blurb}</p>
            <ul class="mt-4 flex flex-col gap-2">
              <li
                :for={note <- @step.notes}
                class="flex gap-2.5 text-[13px] leading-snug text-muted"
              >
                <span class="mt-[6px] h-1.5 w-1.5 flex-none rounded-full bg-brand" />
                <span>{note}</span>
              </li>
            </ul>
          </div>
        </div>

        <div class="mt-7 flex items-center gap-4 border-t border-line pt-5">
          <div class="flex flex-1 items-center gap-1.5">
            <button
              :for={{step, position} <- Enum.with_index(@steps)}
              type="button"
              phx-click={@on_goto}
              phx-value-index={position}
              aria-label={"Passo #{position + 1}: #{step.title}"}
              aria-current={to_string(position == @index)}
              class={[
                "h-2 rounded-full transition-all",
                (position == @index && "w-6 bg-brand") || "w-2 bg-edge hover:bg-brand-light"
              ]}
            />
          </div>

          <button
            :if={not @first?}
            type="button"
            phx-click={@on_prev}
            class="rounded-3xl border border-edge px-4 py-2.5 text-[13px] font-medium text-ink hover:border-brand"
          >
            Indietro
          </button>
          <button
            type="button"
            phx-click={(@last? && @on_close) || @on_next}
            class="rounded-3xl bg-brand px-5 py-2.5 text-[13px] font-bold text-white"
          >
            {(@last? && "Ho capito") || "Avanti"}
          </button>
        </div>
      </div>
    </div>
    """
  end

  # The phone frame every screenshot sits in, so the steps line up with each
  # other and read as shots of the same app.
  attr :step, :atom, required: true

  @spec screenshot(map()) :: Phoenix.LiveView.Rendered.t()
  defp screenshot(assigns) do
    ~H"""
    <figure class="mx-auto w-[268px]">
      <div class="overflow-hidden rounded-[26px] border-[6px] border-brand-night bg-brand-night shadow-[0_18px_40px_rgba(36,28,61,.3)]">
        <div class="relative h-[420px] overflow-hidden rounded-[20px]">
          <.shot_tavolo :if={@step == :tavolo} />
          <.shot_briscola :if={@step == :briscola} />
          <.shot_mano :if={@step == :mano} />
          <.shot_prese :if={@step == :prese} />
          <.shot_dichiarazioni :if={@step == :dichiarazioni} />
          <.shot_marafona :if={@step == :marafona} />
          <.shot_punti :if={@step == :punti} />
        </div>
      </div>
      <figcaption class="mt-2.5 text-center font-mono text-[10px] uppercase tracking-[.12em] text-muted">
        {caption(@step)}
      </figcaption>
    </figure>
    """
  end

  @spec shot_tavolo(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_tavolo(assigns) do
    assigns = assign(assigns, cards: hand(nil))

    ~H"""
    <div class="felt flex h-full flex-col text-white">
      <div class="flex flex-none flex-col items-center gap-1.5 pt-4">
        <.covered_cards count={4} />
        <.seat_label name="Learco" role="compagno" accent="bg-brand" />
      </div>

      <div class="relative flex flex-1 items-center justify-center">
        <div class="absolute left-2 top-1/2 flex -translate-y-1/2 flex-col items-center gap-1.5">
          <.covered_cards count={3} orientation={:vertical} />
          <.seat_label name="Ilva" accent="bg-table-blue" />
        </div>
        <div class="absolute right-2 top-1/2 flex -translate-y-1/2 flex-col items-center gap-1.5">
          <.covered_cards count={3} orientation={:vertical} />
          <.seat_label name="Secondo" accent="bg-table-green" />
        </div>
        <div class="rounded-xl bg-black/30 px-3 py-2 text-center">
          <div class="font-mono text-[9px] tracking-[.12em] text-lilac">MAZZO</div>
          <div class="font-display text-lg">40</div>
        </div>
      </div>

      <div class="flex flex-none flex-col items-center gap-3.5 pb-5">
        <.hand_fan cards={@cards} width={34} height={50} overlap={22} />
        <.seat_label name="Tu" role="10 carte" accent="bg-brand-light" />
      </div>
    </div>
    """
  end

  @spec shot_briscola(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_briscola(assigns) do
    assigns = assign(assigns, suits: @suits, cards: hand(nil))

    ~H"""
    <div class="felt flex h-full flex-col px-4 pt-4 text-white">
      <p class="flex-none font-mono text-[9px] uppercase leading-none tracking-[.12em] text-lilac">
        Mano 1 · sei il battezzante
      </p>
      <h3 class="mt-2 flex-none text-center font-display text-[22px] leading-tight">
        Scegli la briscola
      </h3>

      <div class="mt-4 grid flex-none grid-cols-2 gap-2">
        <.suit_option
          :for={suit <- @suits}
          suit={suit.name}
          held={suit.held}
          selected={suit.name == "Coppe"}
          compact
        />
      </div>

      <div class="mt-3 flex-none rounded-3xl bg-brand py-2.5 text-center text-[13px] font-bold">
        Chiama coppe
      </div>

      <div class="flex flex-1 items-end justify-center pb-5">
        <.hand_fan cards={@cards} width={34} height={50} overlap={22} />
      </div>
    </div>
    """
  end

  @spec shot_mano(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_mano(assigns) do
    assigns = assign(assigns, cards: hand(4))

    ~H"""
    <div class="felt flex h-full flex-col justify-center gap-6 px-4 text-white">
      <div>
        <p class="font-mono text-[9px] uppercase tracking-[.12em] text-lilac">1a · ventaglio</p>
        <div class="mt-3">
          <.hand_fan cards={@cards} width={40} height={58} overlap={26} lift={10} />
        </div>
      </div>

      <div class="border-t border-white/15 pt-5">
        <p class="font-mono text-[9px] uppercase tracking-[.12em] text-lilac">1b · griglia 2×5</p>
        <div class="mt-3">
          <.hand_grid cards={@cards} />
        </div>
      </div>
    </div>
    """
  end

  @spec shot_prese(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_prese(assigns) do
    assigns = assign(assigns, trick: @trick, order: ~w(3 2 A Re Cav Fan 7 6 5 4))

    ~H"""
    <div class="felt flex h-full flex-col items-center px-4 pt-4 text-white">
      <div class="flex-none rounded-[9px] bg-black/30 px-2.5 py-1.5 font-mono text-[10px] text-lilac-soft">
        presa 6/10 · briscola coppe
      </div>

      <div class="mt-5 flex-none">
        <.trick_area played={@trick} compact />
      </div>

      <p class="mt-4 flex-none text-center text-[11px] leading-snug text-lilac-soft">
        Il bordo viola segna la carta che sta vincendo.
      </p>

      <div class="mt-auto w-full flex-none pb-5">
        <p class="mb-2 text-center font-mono text-[9px] uppercase tracking-[.12em] text-lilac">
          dalla più forte
        </p>
        <div class="grid grid-cols-5 gap-1">
          <span
            :for={rank <- @order}
            class="rounded border border-white/20 bg-white/10 py-1 text-center font-mono text-[10px] leading-none"
          >
            {rank}
          </span>
        </div>
      </div>
    </div>
    """
  end

  @spec shot_dichiarazioni(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_dichiarazioni(assigns) do
    assigns =
      assign(assigns,
        calls: [
          {"Busso", "gioca la tua più alta"},
          {"Striscio", "me ne restano poche"},
          {"Volo", "non ne ho più"}
        ]
      )

    ~H"""
    <div class="felt flex h-full flex-col px-4 pt-5 text-white">
      <p class="flex-none font-mono text-[9px] uppercase tracking-[.12em] text-lilac">
        apri tu la presa
      </p>

      <div class="mt-4 flex-none">
        <.declaration_bar />
      </div>

      <ul class="mt-6 flex flex-1 flex-col gap-3">
        <li :for={{call, meaning} <- @calls} class="rounded-xl bg-black/25 px-3 py-2.5">
          <div class="text-[13px] font-semibold">{call}</div>
          <div class="mt-0.5 text-[11px] leading-snug text-lilac-soft">{meaning}</div>
        </li>
      </ul>

      <p class="flex-none pb-5 text-[11px] leading-snug text-lilac">
        Solo chi apre la presa, una sola volta.
      </p>
    </div>
    """
  end

  @spec shot_marafona(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_marafona(assigns) do
    assigns = assign(assigns, marafona: ~w(A 2 3))

    ~H"""
    <div class="felt flex h-full flex-col justify-center gap-6 px-4 text-white">
      <div class="flex justify-center gap-2">
        <div
          :for={rank <- @marafona}
          class="card-weave-picked flex h-[76px] w-[52px] items-end justify-center rounded-[7px] border border-brand pb-1.5 font-mono text-[11px] text-brand-deep shadow-[0_3px_12px_rgba(0,0,0,.45)]"
        >
          {rank}
        </div>
      </div>
      <p class="text-center font-mono text-[10px] uppercase tracking-[.12em] text-lilac">
        asso, 2 e 3 di coppe
      </p>

      <div class="rounded-2xl border border-brand-light bg-brand-deep px-3.5 py-3">
        <div class="text-[12px] font-semibold">Hai la marafona di coppe</div>
        <p class="mt-1 text-[10px] leading-snug text-lilac-soft">
          +3 punti, ma dici dove stanno 3, 2 e asso.
        </p>
        <div class="mt-2.5 flex gap-2">
          <div class="flex-1 rounded-3xl bg-brand py-2 text-center text-[11px] font-bold">
            Dichiara
          </div>
          <div class="flex-1 rounded-3xl border border-white/35 py-2 text-center text-[11px]">
            Passa
          </div>
        </div>
      </div>
    </div>
    """
  end

  @spec shot_punti(map()) :: Phoenix.LiveView.Rendered.t()
  defp shot_punti(assigns) do
    assigns =
      assign(assigns,
        rows: [
          {"Asso", "1"},
          {"3, 2, Re, Cavallo, Fante", "⅓"},
          {"7, 6, 5, 4", "0"},
          {"Ultima presa", "1"}
        ]
      )

    ~H"""
    <div class="felt flex h-full flex-col px-4 pt-4 text-white">
      <div class="flex flex-none gap-1.5">
        <div class="flex-1 rounded-[9px] border border-brand/50 bg-brand/20 px-2.5 py-1.5">
          <div class="font-mono text-[9px] tracking-[.1em] text-lilac">NOI</div>
          <div class="text-[15px] font-bold text-white">24</div>
        </div>
        <div class="flex-1 rounded-[9px] bg-black/25 px-2.5 py-1.5">
          <div class="font-mono text-[9px] tracking-[.1em] text-lilac">LORO</div>
          <div class="text-[15px] font-bold">17</div>
        </div>
        <div class="flex-1 rounded-[9px] bg-black/25 px-2.5 py-1.5">
          <div class="font-mono text-[9px] tracking-[.1em] text-lilac">MANO</div>
          <div class="font-mono text-[13px] text-lilac-soft">10/10</div>
        </div>
      </div>

      <ul class="mt-5 flex-none divide-y divide-white/10 overflow-hidden rounded-xl bg-black/25">
        <li :for={{what, worth} <- @rows} class="flex items-center gap-2 px-3 py-2.5">
          <span class="min-w-0 flex-1 text-[12px] leading-snug">{what}</span>
          <span class="flex-none font-mono text-[13px] font-bold text-lilac-soft">{worth}</span>
        </li>
      </ul>

      <div class="mt-auto flex-none pb-5 text-center">
        <div class="font-display text-[30px] leading-none">11⅓</div>
        <p class="mt-1.5 text-[11px] leading-snug text-lilac">
          punti in gioco a ogni mano.<br />La partita si vince a 41.
        </p>
      </div>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :role, :string, default: nil
  attr :accent, :string, required: true

  @spec seat_label(map()) :: Phoenix.LiveView.Rendered.t()
  defp seat_label(assigns) do
    ~H"""
    <div class="flex items-center gap-1.5">
      <div class={["h-3.5 w-3.5 flex-none rounded-full", @accent]} />
      <span class="text-[11px] font-medium">{@name}</span>
      <span :if={@role} class="font-mono text-[9px] text-lilac">{@role}</span>
    </div>
    """
  end

  @spec hand(integer() | nil) :: [map()]
  defp hand(selected) do
    for index <- 1..10, do: %{index: index, selected: index == selected, playable: true}
  end

  @spec caption(atom()) :: String.t()
  defp caption(:tavolo), do: "il tavolo · quattro posti"
  defp caption(:briscola), do: "schermata · scelta della briscola"
  defp caption(:mano), do: "le due presentazioni della mano"
  defp caption(:prese), do: "schermata · tavolo, presa in corso"
  defp caption(:dichiarazioni), do: "schermata · tavolo, dichiarazioni"
  defp caption(:marafona), do: "schermata · tavolo, marafona"
  defp caption(:punti), do: "schermata · punteggio di mano"
end
