defmodule AverzianoWeb.Live.Prototipi do
  @moduledoc """
  Entry point for the screen prototypes: two variants, identical except for
  how the hand is presented, each walkable end to end.
  """
  use AverzianoWeb, :live_view

  alias AverzianoWeb.Live.HandVariant

  @screens [
    {:lobby, "Lobby", "elenco tavoli, ruleset in chiaro"},
    {:briscola, "Scelta della briscola", "battezzata, senza segni"},
    {:tavolo, "Tavolo", "presa 6 di 10 · ruota con il telefono"}
  ]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Prototipi", screens: @screens)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-[760px] px-8 py-14">
      <p class="font-mono text-xs uppercase leading-none tracking-[.16em] text-muted">
        Turno 1 · strutture
      </p>
      <h1 class="mt-2.5 font-display text-[44px] leading-tight tracking-[-.01em]">
        Beccaccino online — impianti di schermata
      </h1>
      <p class="mt-2.5 text-[15px] leading-relaxed text-prose">
        Due varianti a confronto, identiche in tutto tranne la <strong class="font-semibold text-ink">presentazione della mano</strong>: 1a a ventaglio,
        1b a griglia 2×5. Le carte sono segnaposto neutri.
      </p>

      <div class="mt-10 grid gap-6 sm:grid-cols-2">
        <section
          :for={{tag, variant} <- [{"1a", :ventaglio}, {"1b", :griglia}]}
          class="rounded-2xl border border-edge bg-white p-6"
        >
          <div class="flex items-baseline gap-3.5">
            <span class="rounded-3xl bg-brand px-2.5 py-1.5 font-mono text-[11px] leading-none tracking-[.12em] text-white">
              {tag}
            </span>
            <h2 class="font-display text-[22px]">{HandVariant.label(variant)}</h2>
          </div>
          <ul class="mt-5 flex flex-col gap-2.5">
            <li :for={{screen, name, note} <- @screens}>
              <.link
                navigate={screen_path(screen, HandVariant.to_param(variant))}
                class="block rounded-xl border border-edge px-3.5 py-3 no-underline hover:border-brand"
              >
                <span class="text-[15px] font-medium text-ink">{name}</span>
                <span class="mt-0.5 block text-xs text-muted">{note}</span>
              </.link>
            </li>
          </ul>
        </section>
      </div>
    </div>
    """
  end

  @spec screen_path(:lobby | :briscola | :tavolo, String.t()) :: String.t()
  defp screen_path(:lobby, mano), do: ~p"/prototipi/lobby?mano=#{mano}"
  defp screen_path(:briscola, mano), do: ~p"/prototipi/briscola?mano=#{mano}"
  defp screen_path(:tavolo, mano), do: ~p"/prototipi/tavolo?mano=#{mano}"
end
