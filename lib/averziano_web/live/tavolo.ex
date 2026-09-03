defmodule AverzianoWeb.Live.Tavolo do
  @moduledoc """
  The table mid-hand: trick six of ten, marafona on offer, your turn to play.

  Portrait stacks partner, trick and hand vertically. Landscape switches to the
  design's own three-column layout — score rail, table, declaration rail — and
  is picked up straight from the viewport's orientation.
  """
  use AverzianoWeb, :live_view

  import AverzianoWeb.GameComponents

  alias AverzianoWeb.Live.HandVariant

  @trick [
    %{position: "left:50%;top:0;transform:translateX(-50%) rotate(-4deg)"},
    %{position: "left:0;top:62px;transform:rotate(6deg)"},
    %{position: "right:0;top:62px;transform:rotate(-7deg)", winning: true}
  ]

  @trick_compact [
    %{position: "left:50%;top:0;transform:translateX(-50%) rotate(-4deg)"},
    %{position: "left:22px;top:30px;transform:rotate(6deg)"},
    %{position: "right:22px;top:30px;transform:rotate(-7deg)", winning: true}
  ]

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Tavolo", trick: @trick, trick_compact: @trick_compact)
     |> assign(us: 24, them: 17, briscola: "Coppe", played: "6/10")
     |> assign(cards: hand(6))}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, variant: HandVariant.from_params(params))}
  end

  @impl Phoenix.LiveView
  def handle_event("pick", %{"index" => index}, socket) do
    {:noreply, assign(socket, cards: hand(String.to_integer(index)))}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="felt mx-auto min-h-dvh w-full text-white landscape:max-w-none portrait:max-w-[420px]">
      <div id="tavolo-verticale" class="flex min-h-dvh flex-col landscape:hidden">
        <div class="flex-none px-[18px] pt-1">
          <.score_strip us={@us} them={@them} briscola={@briscola} trick={@played} />
        </div>

        <div class="flex flex-none flex-col items-center gap-[7px] pt-4">
          <.player_seat name="Learco" role="compagno" cards={4} />
        </div>

        <div class="relative flex flex-1 items-center justify-center">
          <div class="absolute left-3.5 top-1/2 -translate-y-1/2">
            <.player_seat name="Ilva" accent="bg-table-blue" cards={3} orientation={:vertical} />
          </div>
          <div class="absolute right-3.5 top-1/2 -translate-y-1/2">
            <.player_seat name="Secondo" accent="bg-table-green" cards={3} orientation={:vertical} />
          </div>
          <.trick_area played={@trick} />
        </div>

        <div class="mx-[18px] mb-3 flex flex-none items-center gap-3 rounded-2xl border border-brand-light bg-brand-deep px-3.5 py-[13px]">
          <div class="flex-1">
            <div class="text-[13px] font-semibold text-white">Hai la marafona di coppe</div>
            <p class="mt-[3px] text-[11px] leading-snug text-lilac-soft">
              +3 punti, ma dici dove stanno 3, 2 e asso.
            </p>
          </div>
          <button
            type="button"
            class="flex-none rounded-3xl bg-brand px-[15px] py-[9px] text-[13px] font-bold text-white"
          >
            Dichiara
          </button>
          <button
            type="button"
            class="flex-none rounded-3xl border border-white/35 px-[15px] py-[9px] text-[13px] text-white"
          >
            Passa
          </button>
        </div>

        <div class="flex flex-none items-center gap-2 px-[18px] pb-2.5">
          <.declaration_bar />
          <button
            type="button"
            class="h-11 w-[52px] flex-none rounded-3xl border border-white/35 font-mono text-[10px] text-white"
          >
            fuori
          </button>
        </div>

        <div class={[
          "flex flex-none items-end justify-center",
          (@variant == :ventaglio && "h-[158px] pb-8") || "px-[18px] pb-7"
        ]}>
          <.hand_fan :if={@variant == :ventaglio} cards={@cards} on_pick="pick" />
          <.hand_grid :if={@variant == :griglia} cards={@cards} on_pick="pick" />
        </div>
      </div>

      <div id="tavolo-orizzontale" class="hidden min-h-dvh landscape:flex">
        <div class="flex w-[118px] flex-none flex-col gap-[9px] bg-black/20 p-[18px_14px]">
          <div class="rounded-[9px] border border-brand/50 bg-brand/20 px-2.5 py-2">
            <div class="font-mono text-[10px] tracking-[.1em] text-lilac">NOI</div>
            <div class="text-xl font-bold text-white">{@us}</div>
          </div>
          <div class="rounded-[9px] bg-black/30 px-2.5 py-2">
            <div class="font-mono text-[10px] tracking-[.1em] text-lilac">LORO</div>
            <div class="text-xl font-bold">{@them}</div>
          </div>
          <div class="rounded-[9px] bg-black/30 px-2.5 py-2">
            <div class="font-mono text-[10px] tracking-[.1em] text-lilac">BRISCOLA</div>
            <div class="font-display text-[19px]">{@briscola}</div>
          </div>
          <div class="rounded-[9px] bg-black/30 px-2.5 py-2 font-mono text-[11px] text-lilac-soft">
            presa {@played}
          </div>
          <div class="flex-1" />
          <button
            type="button"
            class="rounded-3xl border border-white/35 px-2.5 py-[11px] text-center text-xs text-white"
          >
            Mi chiamo fuori
          </button>
        </div>

        <div class="relative flex flex-1 flex-col">
          <div class="flex flex-none items-start justify-between px-[22px] pt-3.5">
            <div class="flex items-center gap-2">
              <div class="h-[22px] w-[22px] rounded-full bg-table-blue" />
              <span class="text-xs text-white">Ilva</span>
              <span class="font-mono text-[10px] text-lilac">3</span>
            </div>
            <.player_seat name="Learco" role="compagno" cards={4} />
            <div class="flex items-center gap-2">
              <span class="font-mono text-[10px] text-lilac">3</span>
              <span class="text-xs text-white">Secondo</span>
              <div class="h-[22px] w-[22px] rounded-full bg-table-green" />
            </div>
          </div>

          <div class="flex flex-1 items-center justify-center">
            <.trick_area played={@trick_compact} compact />
          </div>

          <div class={[
            "flex flex-none items-end justify-center",
            (@variant == :ventaglio && "h-[118px] pb-6") || "px-[22px] pb-5"
          ]}>
            <.hand_fan
              :if={@variant == :ventaglio}
              cards={@cards}
              width={48}
              height={70}
              overlap={28}
              lift={12}
              on_pick="pick"
            />
            <.hand_grid :if={@variant == :griglia} cards={@cards} columns={10} on_pick="pick" />
          </div>
        </div>

        <div class="flex w-[110px] flex-none flex-col gap-[9px] bg-black/20 p-[18px_14px]">
          <div class="font-mono text-[10px] tracking-[.1em] text-lilac">DICHIARI</div>
          <.declaration_bar layout={:column} />
          <div class="flex-1" />
          <p class="text-[10px] leading-snug text-lilac">
            Solo chi apre la presa, una sola volta.
          </p>
        </div>
      </div>
    </div>
    """
  end

  # Cards 8 to 10 are out of play this trick; the design fades them rather than
  # hiding them, so the hand keeps its shape.
  @spec hand(integer()) :: [map()]
  defp hand(selected) do
    for index <- 1..10 do
      %{index: index, selected: index == selected, playable: index <= 7}
    end
  end
end
