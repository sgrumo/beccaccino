defmodule AverzianoWeb.Live.Briscola do
  @moduledoc """
  Calling briscola as the battezzante: no discussion, no signals, decide now.

  The fan variant spreads the four suits over a 2x2 grid and keeps room for
  the partner note and the monte escape hatch; the grid variant compresses the
  suits into a single row so the whole hand fits above the confirm button.
  """
  use AverzianoWeb, :live_view

  import AverzianoWeb.GameComponents

  alias AverzianoWeb.Live.HandVariant

  @suits [
    %{name: "Denari", held: "4 carte in mano", short: "4"},
    %{name: "Coppe", held: "4 carte · A 2 3", short: "4"},
    %{name: "Spade", held: "1 carta", short: "1"},
    %{name: "Bastoni", held: "1 carta", short: "1"}
  ]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    cards = for index <- 1..10, do: %{index: index, selected: false, playable: true}

    {:ok,
     assign(socket,
       page_title: "Scegli la briscola",
       suits: @suits,
       called: "Coppe",
       cards: cards
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, variant: HandVariant.from_params(params))}
  end

  @impl Phoenix.LiveView
  def handle_event("call", %{"suit" => suit}, socket) do
    {:noreply, assign(socket, called: suit)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="felt mx-auto flex min-h-dvh w-full max-w-[420px] flex-col text-white">
      <div class="flex-none px-[22px] pt-1.5">
        <p class="font-mono text-[11px] uppercase leading-none tracking-[.12em] text-lilac">
          Mano 3 · sei il battezzante
        </p>
      </div>

      <div class={[
        "flex-none px-[22px]",
        (@variant == :ventaglio && "pt-[26px] text-center") || "pt-[18px]"
      ]}>
        <h1 class={[
          "font-display leading-[1.1]",
          (@variant == :ventaglio && "text-[32px]") || "text-[30px]"
        ]}>
          Scegli la briscola
        </h1>
        <p :if={@variant == :ventaglio} class="mt-2 text-[13px] leading-normal text-lilac">
          Nessuna discussione, nessun segno.<br />Devi scegliere adesso.
        </p>
        <p :if={@variant == :griglia} class="mt-1.5 text-xs text-lilac">
          Il compagno vede le carte solo dopo.
        </p>
      </div>

      <div
        :if={@variant == :ventaglio}
        class="grid flex-none grid-cols-2 gap-3 px-[22px] pt-6"
      >
        <.suit_option
          :for={suit <- @suits}
          suit={suit.name}
          held={suit.held}
          selected={suit.name == @called}
          on_select="call"
        />
      </div>

      <div :if={@variant == :griglia} class="flex flex-none gap-2 px-[22px] pt-4">
        <.suit_option
          :for={suit <- @suits}
          suit={suit.name}
          held={suit.short}
          selected={suit.name == @called}
          compact
          on_select="call"
        />
      </div>

      <div
        :if={@variant == :ventaglio}
        class="mx-[22px] mt-5 flex flex-none items-center gap-[11px] rounded-xl bg-black/30 px-[15px] py-[13px]"
      >
        <div class="card-cover h-[30px] w-[22px] flex-none rounded" />
        <p class="text-xs leading-snug text-lilac-soft">
          Il tuo compagno <strong class="font-medium text-white">Learco</strong> tiene le carte
          coperte finché non annunci.
        </p>
      </div>

      <div
        :if={@variant == :griglia}
        class="flex flex-1 flex-col justify-center px-[22px] py-5"
      >
        <p class="mb-3 font-mono text-[10px] uppercase tracking-[.12em] text-lilac">
          La tua mano · raggruppata per seme
        </p>
        <.hand_grid cards={@cards} />
      </div>

      <div
        :if={@variant == :ventaglio}
        class="flex flex-1 flex-col justify-end gap-2.5 px-[22px] pb-4"
      >
        <div class="flex items-center gap-3 rounded-[13px] border border-dashed border-white/30 p-3.5">
          <div class="flex-1">
            <div class="text-[13px] font-medium">Manda a monte</div>
            <p class="mt-[3px] text-[11px] leading-snug text-lilac">
              La tua mano vale 1⅓: puoi farla rifare allo stesso mazziere.
            </p>
          </div>
          <button
            type="button"
            class="flex-none rounded-[9px] border border-white/25 px-[13px] py-[9px] text-xs text-white"
          >
            A monte
          </button>
        </div>
        <.link
          navigate={~p"/prototipi/tavolo?mano=#{HandVariant.to_param(@variant)}"}
          class="block rounded-3xl bg-brand p-[15px] text-center text-[15px] font-bold text-white"
        >
          Chiama {String.downcase(@called)}
        </.link>
      </div>

      <div
        :if={@variant == :griglia}
        class="flex flex-none items-center gap-2.5 px-[22px] pb-[30px]"
      >
        <.link
          navigate={~p"/prototipi/tavolo?mano=#{HandVariant.to_param(@variant)}"}
          class="flex-1 rounded-3xl bg-brand p-[15px] text-center text-[15px] font-bold text-white"
        >
          Chiama {String.downcase(@called)}
        </.link>
        <button
          type="button"
          class="flex-none rounded-3xl border border-white/35 px-3.5 py-[15px] text-[13px] text-white"
        >
          A monte
        </button>
      </div>

      <div
        :if={@variant == :ventaglio}
        class="flex h-[150px] flex-none items-end justify-center pb-[34px]"
      >
        <.hand_fan cards={@cards} width={50} height={74} />
      </div>
    </div>
    """
  end
end
