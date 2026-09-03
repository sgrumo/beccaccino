defmodule AverzianoWeb.Live.Lobby do
  @moduledoc """
  Table list. The active ruleset sits in plain sight on every card, because
  the first argument is always about the rules rather than the cards.

  The fan variant leads with the list behind three tabs; the grid variant
  hoists the two actions people actually use to the top.
  """
  use AverzianoWeb, :live_view

  import AverzianoWeb.GameComponents

  alias AverzianoWeb.Live.HandVariant

  @tables [
    %{
      name: "Osteria di Faenza",
      ruleset: "Tradizionale · 41 e una figura · punti nascosti",
      short: "Tradizionale · punti nascosti",
      seats: "3/4",
      accent: "bg-brand",
      action: "entra",
      full: false
    },
    %{
      name: "Tavolo dei Nonni",
      ruleset: "Facile · 31 · punti visibili",
      short: "Facile · 31 · punti visibili",
      seats: "2/4",
      accent: "bg-table-blue",
      action: "entra",
      full: false
    },
    %{
      name: "Cesena, la bella",
      ruleset: "Tradizionale · meglio di tre · marafona dichiarata",
      short: "Meglio di tre · marafona dichiarata",
      seats: "4/4",
      accent: "bg-table-green",
      action: "osserva",
      full: true
    },
    %{
      name: "Ravenna rapido",
      ruleset: "Tradizionale · 21 · senza dichiarazioni",
      short: "21 · senza dichiarazioni",
      seats: "1/4",
      accent: "bg-table-olive",
      action: "entra",
      full: false
    }
  ]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Lobby", tables: @tables, tab: :aperti)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, variant: HandVariant.from_params(params))}
  end

  @impl Phoenix.LiveView
  def handle_event("tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, tab: String.to_existing_atom(tab))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="mx-auto flex min-h-dvh w-full max-w-[420px] flex-col bg-white">
      <header class="flex-none px-[22px] pb-[18px] pt-2">
        <h1 class="font-display text-[34px] leading-[1.05]">Beccaccino</h1>
        <p class="mt-1.5 font-mono text-[11px] uppercase leading-none tracking-[.14em] text-muted">
          Romagna · in linea
        </p>
      </header>

      <div :if={@variant == :ventaglio} class="flex flex-none gap-1.5 px-[22px] pb-4">
        <button
          :for={
            {key, label} <- [
              {:aperti, "Tavoli aperti"},
              {:amici, "Amici"},
              {:classifica, "Classifica"}
            ]
          }
          type="button"
          phx-click="tab"
          phx-value-tab={key}
          class={[
            "flex-1 rounded-[10px] py-2.5 text-center text-[13px]",
            (key == @tab && "bg-brand font-medium text-white") || "text-muted"
          ]}
        >
          {label}
        </button>
      </div>

      <div :if={@variant == :griglia} class="flex flex-none gap-2 px-[22px] pb-1">
        <div class="flex-1 rounded-xl bg-brand p-[13px] text-center text-white">
          <div class="text-sm font-medium">Partita rapida</div>
          <div class="mt-1 font-mono text-[10px] text-lilac-soft">Tradizionale · 41</div>
        </div>
        <div class="flex-1 rounded-xl border border-edge p-[13px] text-center">
          <div class="text-sm font-medium">Crea tavolo</div>
          <div class="mt-1 font-mono text-[10px] text-muted">scegli le regole</div>
        </div>
      </div>

      <div class="flex flex-1 flex-col gap-2.5 px-[22px]">
        <div
          :if={@variant == :griglia}
          class="mt-2 font-mono text-[10px] uppercase tracking-[.12em] text-muted"
        >
          Tavoli aperti · {length(@tables)}
        </div>

        <.link
          :for={table <- @tables}
          navigate={~p"/prototipi/tavolo?mano=#{HandVariant.to_param(@variant)}"}
        >
          <.table_row
            name={table.name}
            ruleset={(@variant == :griglia && table.short) || table.ruleset}
            seats={table.seats}
            accent={table.accent}
            action={table.action}
            full={table.full}
            square_avatar={@variant == :griglia}
          />
        </.link>

        <p
          :if={@variant == :ventaglio}
          class="mt-1.5 rounded-2xl border border-dashed border-edge p-3.5 text-xs leading-normal text-muted"
        >
          Il ruleset attivo è sempre in chiaro sulla scheda del tavolo: la prima discussione è
          sulle regole, non sulle carte.
        </p>
      </div>

      <div :if={@variant == :ventaglio} class="flex-none px-[22px] pb-2.5 pt-4">
        <.link
          navigate={~p"/prototipi/briscola?mano=#{HandVariant.to_param(@variant)}"}
          class="block rounded-3xl bg-brand p-[15px] text-center text-[15px] font-bold text-white"
        >
          Crea tavolo
        </.link>
      </div>

      <.bottom_nav active={:gioca} />
    </div>
    """
  end
end
