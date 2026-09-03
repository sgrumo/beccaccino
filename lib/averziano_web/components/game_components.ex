defmodule AverzianoWeb.GameComponents do
  @moduledoc """
  Presentational pieces of the Beccaccino table, shared by both hand variants.

  Card faces are deliberately neutral placeholders: the design leaves the
  artwork out, so a card shows only its index and its state (playable,
  selected, out of play).
  """
  use Phoenix.Component

  # Fan geometry, straight from the design: rotation in degrees and the lift
  # that keeps the arc's outer cards from dropping below the inner ones.
  @fan_layout [
    {-20, 0},
    {-16, 6},
    {-12, 3},
    {-8, 1},
    {-3, 0},
    {3, 0},
    {8, 1},
    {12, 3},
    {16, 6},
    {20, 0}
  ]

  @doc """
  A single card in the player's hand.

  Renders as a button so a hand is keyboard-navigable; unplayable cards are
  faded and disabled rather than hidden.
  """
  attr :index, :integer, required: true
  attr :selected, :boolean, default: false
  attr :playable, :boolean, default: true
  attr :style, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global

  @spec hand_card(map()) :: Phoenix.LiveView.Rendered.t()
  def hand_card(assigns) do
    ~H"""
    <button
      type="button"
      disabled={not @playable}
      aria-pressed={to_string(@selected)}
      aria-label={"Carta #{@index}"}
      style={@style}
      class={[
        "relative rounded-[7px] border shadow-[0_3px_12px_rgba(0,0,0,.45)] origin-bottom",
        "transition-transform duration-150 ease-out",
        (@selected && "card-weave-picked outline outline-2 outline-brand") ||
          "card-weave",
        (@playable && "border-edge") || "border-card-edge grayscale brightness-[.86]",
        @class
      ]}
      {@rest}
    >
      <span class="absolute bottom-1 right-1.5 font-mono text-[9px] text-card-edge">
        {label(@index)}
      </span>
    </button>
    """
  end

  @doc """
  Variant 1a: ten cards overlapped into an arc, thumb-first.

  Trades rank visibility for a shorter hand, which leaves the table area wider.
  """
  attr :cards, :list, required: true
  attr :width, :integer, default: 52
  attr :height, :integer, default: 76
  attr :overlap, :integer, default: 34
  attr :lift, :integer, default: 14
  attr :on_pick, :string, default: nil

  @spec hand_fan(map()) :: Phoenix.LiveView.Rendered.t()
  def hand_fan(assigns) do
    assigns = assign(assigns, :layout, Enum.zip(assigns.cards, @fan_layout))

    ~H"""
    <div
      class="flex items-end justify-center"
      data-hand="ventaglio"
      role="group"
      aria-label="La tua mano"
    >
      <.hand_card
        :for={{{card, {angle, drop}}, position} <- Enum.with_index(@layout)}
        index={card.index}
        selected={card.selected}
        playable={card.playable}
        phx-click={@on_pick}
        phx-value-index={card.index}
        style={
          fan_style(%{
            width: @width,
            height: @height,
            overlap: (position > 0 && @overlap) || 0,
            angle: angle,
            drop: drop,
            selected: card.selected,
            lift: @lift
          })
        }
      />
    </div>
    """
  end

  @doc """
  Variant 1b: every card fully visible on a 2x5 grid.

  Costs vertical space — the table area above it is shorter — but nothing is
  covered. Pass `columns: 10` for the single row the landscape table uses.
  """
  attr :cards, :list, required: true
  attr :columns, :integer, default: 5
  attr :on_pick, :string, default: nil

  @spec hand_grid(map()) :: Phoenix.LiveView.Rendered.t()
  def hand_grid(assigns) do
    ~H"""
    <div
      class={[
        "grid w-full gap-2",
        (@columns == 10 && "grid-cols-10") || "grid-cols-5"
      ]}
      data-hand="griglia"
      role="group"
      aria-label="La tua mano"
    >
      <.hand_card
        :for={card <- @cards}
        index={card.index}
        selected={card.selected}
        playable={card.playable}
        phx-click={@on_pick}
        phx-value-index={card.index}
        class={[
          "aspect-[2/3] w-full rounded-lg",
          card.selected && "-translate-y-1"
        ]}
      />
    </div>
    """
  end

  @doc """
  A fanned stack of covered cards, for the partner and the two opponents.
  """
  attr :count, :integer, default: 4
  attr :orientation, :atom, values: [:horizontal, :vertical], default: :horizontal

  @spec covered_cards(map()) :: Phoenix.LiveView.Rendered.t()
  def covered_cards(assigns) do
    ~H"""
    <div class={[
      "flex",
      (@orientation == :vertical && "flex-col") || "items-end"
    ]}>
      <div
        :for={position <- 0..(@count - 1)}
        class={[
          "card-cover rounded",
          (@orientation == :vertical && "h-6 w-[34px]") || "h-[34px] w-6",
          position > 0 && ((@orientation == :vertical && "-mt-[13px]") || "-ml-3")
        ]}
      />
    </div>
    """
  end

  @doc """
  One seat at the table: covered cards plus who is sitting there.
  """
  attr :name, :string, required: true
  attr :role, :string, default: nil
  attr :accent, :string, default: "bg-brand"
  attr :cards, :integer, default: 3
  attr :orientation, :atom, values: [:horizontal, :vertical], default: :horizontal

  @spec player_seat(map()) :: Phoenix.LiveView.Rendered.t()
  def player_seat(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-[7px]">
      <.covered_cards count={@cards} orientation={@orientation} />
      <div class="flex items-center gap-[7px]">
        <div class={["h-[22px] w-[22px] flex-none rounded-full", @accent]} />
        <span class="text-[13px] font-medium">{@name}</span>
        <span :if={@role} class="font-mono text-[10px] text-lilac">{@role}</span>
      </div>
    </div>
    """
  end

  @doc """
  The trick in progress: cards already played, plus the slot waiting on you.
  """
  attr :played, :list, required: true
  attr :your_turn, :boolean, default: true
  attr :compact, :boolean, default: false

  @spec trick_area(map()) :: Phoenix.LiveView.Rendered.t()
  def trick_area(assigns) do
    ~H"""
    <div class={[
      "relative",
      (@compact && "h-28 w-[250px]") || "h-[210px] w-[190px]"
    ]}>
      <div
        :for={card <- @played}
        style={card.position}
        class={[
          "card-weave absolute rounded-md shadow-[0_3px_10px_rgba(0,0,0,.4)]",
          (@compact && "h-[68px] w-[46px]") || "h-[76px] w-[52px]",
          (card[:winning] && "border-2 border-brand shadow-[0_0_0_3px_rgba(94,48,230,.2)]") ||
            "border border-edge"
        ]}
      />
      <div
        style={
          (@compact && "left:50%;bottom:-8px;transform:translateX(-50%)") ||
            "left:50%;bottom:0;transform:translateX(-50%)"
        }
        class={[
          "absolute flex items-center justify-center rounded-md border border-dashed",
          "border-white/30 text-center font-mono text-[9px] text-white/45",
          (@compact && "h-[68px] w-[46px]") || "h-[76px] w-[52px]"
        ]}
      >
        {if @your_turn, do: your_turn_label(@compact), else: "—"}
      </div>
    </div>
    """
  end

  @doc """
  Busso / striscio / volo — announced only by whoever opens the trick.
  """
  attr :calls, :list, default: ["Busso", "Striscio", "Volo"]
  attr :layout, :atom, values: [:row, :column], default: :row

  @spec declaration_bar(map()) :: Phoenix.LiveView.Rendered.t()
  def declaration_bar(assigns) do
    ~H"""
    <div class={[
      "flex gap-2",
      (@layout == :column && "flex-col") || "flex-1 items-center"
    ]}>
      <button
        :for={call <- @calls}
        type="button"
        class={[
          "rounded-3xl border border-white/20 bg-white/10 py-3 text-center",
          "text-[15px] font-medium text-white",
          (@layout == :column && "px-2.5") || "flex-1"
        ]}
      >
        {call}
      </button>
    </div>
    """
  end

  @doc """
  Scores for both pairs, plus the live state of the hand.
  """
  attr :us, :integer, required: true
  attr :them, :integer, required: true
  attr :briscola, :string, required: true
  attr :trick, :string, required: true

  @spec score_strip(map()) :: Phoenix.LiveView.Rendered.t()
  def score_strip(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <div class="flex flex-1 gap-1.5">
        <div class="rounded-[9px] border border-brand/50 bg-brand/20 px-[11px] py-[7px]">
          <span class="font-mono text-[10px] tracking-[.1em] text-lilac">NOI</span>
          <span class="text-[15px] font-bold text-white">{@us}</span>
        </div>
        <div class="rounded-[9px] bg-black/25 px-[11px] py-[7px]">
          <span class="font-mono text-[10px] tracking-[.1em] text-lilac">LORO</span>
          <span class="text-[15px] font-bold">{@them}</span>
        </div>
      </div>
      <div class="rounded-[9px] bg-black/25 px-[11px] py-[7px] font-mono text-[11px] text-lilac-soft">
        {@briscola}
      </div>
      <div class="rounded-[9px] bg-black/25 px-[11px] py-[7px] font-mono text-[11px] text-lilac-soft">
        {@trick}
      </div>
    </div>
    """
  end

  @doc """
  A suit to call as briscola, with how many of it you are holding.
  """
  attr :suit, :string, required: true
  attr :held, :string, required: true
  attr :selected, :boolean, default: false
  attr :compact, :boolean, default: false
  attr :on_select, :string, default: nil

  @spec suit_option(map()) :: Phoenix.LiveView.Rendered.t()
  def suit_option(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@on_select}
      phx-value-suit={@suit}
      aria-pressed={to_string(@selected)}
      class={[
        "rounded-2xl text-left",
        (@compact && "flex-1 px-1.5 py-3 text-center") || "px-4 py-[18px]",
        (@selected && "border-2 border-brand-light bg-white/[.16]") ||
          "border border-white/15 bg-white/[.06]"
      ]}
    >
      <div class={[
        "font-display",
        (@compact && "text-base") || "text-2xl",
        @selected && "font-semibold text-white"
      ]}>
        {@suit}
      </div>
      <div class={[
        "mt-1.5 font-mono text-[10px]",
        (@selected && "text-lilac-soft") || "text-lilac"
      ]}>
        {@held}
      </div>
    </button>
    """
  end

  @doc """
  A table in the lobby list. The ruleset is always spelled out: the first
  argument is about the rules, not the cards.
  """
  attr :name, :string, required: true
  attr :ruleset, :string, required: true
  attr :seats, :string, required: true
  attr :accent, :string, required: true
  attr :action, :string, default: "entra"
  attr :full, :boolean, default: false
  attr :square_avatar, :boolean, default: false

  @spec table_row(map()) :: Phoenix.LiveView.Rendered.t()
  def table_row(assigns) do
    ~H"""
    <div class="flex items-center gap-3 rounded-2xl border border-edge bg-white p-3.5">
      <div class={[
        "h-[38px] w-[38px] flex-none",
        (@square_avatar && "rounded-xl") || "rounded-full",
        @accent
      ]} />
      <div class="min-w-0 flex-1">
        <div class="text-[15px] font-medium">{@name}</div>
        <div class="mt-[3px] text-xs text-muted">{@ruleset}</div>
      </div>
      <div class="flex-none text-right">
        <div class={[
          "font-mono text-[13px] leading-none",
          (@full && "text-muted") || "text-brand"
        ]}>
          {@seats}
        </div>
        <div class="mt-[5px] text-[11px] text-muted">{@action}</div>
      </div>
    </div>
    """
  end

  @doc """
  Lobby tab bar: play, rules, profile.
  """
  attr :active, :atom, values: [:gioca, :regole, :profilo], default: :gioca

  @spec bottom_nav(map()) :: Phoenix.LiveView.Rendered.t()
  def bottom_nav(assigns) do
    ~H"""
    <nav class="flex h-[74px] flex-none items-start justify-around border-t border-line pt-3">
      <div
        :for={
          {key, label, round} <- [
            {:gioca, "Gioca", false},
            {:regole, "Regole", false},
            {:profilo, "Profilo", true}
          ]
        }
        class={[
          "text-center text-[11px]",
          (key == @active && "text-brand") || "text-inactive"
        ]}
      >
        <div class={[
          "mx-auto mb-1.5 h-5 w-5",
          (round && "rounded-full") || "rounded-[5px]",
          (key == @active && "bg-brand") || "bg-line"
        ]} />
        {label}
      </div>
    </nav>
    """
  end

  @spec label(integer()) :: String.t()
  defp label(index), do: index |> Integer.to_string() |> String.pad_leading(2, "0")

  @spec your_turn_label(boolean()) :: String.t()
  defp your_turn_label(true), do: "tu"
  defp your_turn_label(false), do: "tocca a te"

  @spec fan_style(map()) :: String.t()
  defp fan_style(card) do
    shift = if card.selected, do: -card.lift, else: card.drop

    Enum.join(
      [
        "width:#{card.width}px",
        "height:#{card.height}px",
        "margin-left:-#{card.overlap}px",
        "transform:rotate(#{card.angle}deg) translateY(#{shift}px)"
      ],
      ";"
    )
  end
end
