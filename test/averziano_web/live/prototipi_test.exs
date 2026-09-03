defmodule AverzianoWeb.Live.PrototipiTest do
  use AverzianoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "index" do
    test "offers both hand variants", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/prototipi")

      assert html =~ "Mano a ventaglio"
      assert html =~ "Mano a griglia 2×5"
    end
  end

  describe "lobby" do
    test "spells out the ruleset of every open table", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/prototipi/lobby?mano=ventaglio")

      assert html =~ "Osteria di Faenza"
      assert html =~ "Tradizionale · 41 e una figura · punti nascosti"
      assert html =~ "osserva"
    end

    test "the fan variant leads with tabs, the grid variant with quick actions",
         %{conn: conn} do
      {:ok, fan, _html} = live(conn, ~p"/prototipi/lobby?mano=ventaglio")
      {:ok, grid, _html} = live(conn, ~p"/prototipi/lobby?mano=griglia")

      assert has_element?(fan, "button", "Classifica")
      refute render(fan) =~ "Partita rapida"

      assert render(grid) =~ "Partita rapida"
      refute has_element?(grid, "button", "Classifica")
    end

    test "switching tab moves the highlight", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prototipi/lobby?mano=ventaglio")

      view |> element("button[phx-value-tab=amici]") |> render_click()

      assert has_element?(view, "button[phx-value-tab=amici].bg-brand")
      refute has_element?(view, "button[phx-value-tab=aperti].bg-brand")
    end
  end

  describe "briscola" do
    test "calling a different suit updates the confirmation", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/prototipi/briscola?mano=ventaglio")

      assert html =~ "Chiama coppe"

      view |> element("button[phx-value-suit=Spade]") |> render_click()

      assert render(view) =~ "Chiama spade"
    end

    test "each variant shows its own hand layout", %{conn: conn} do
      {:ok, fan, _html} = live(conn, ~p"/prototipi/briscola?mano=ventaglio")
      {:ok, grid, _html} = live(conn, ~p"/prototipi/briscola?mano=griglia")

      assert has_element?(fan, "[data-hand=ventaglio]")
      refute has_element?(fan, "[data-hand=griglia]")

      assert has_element?(grid, "[data-hand=griglia]")
      refute has_element?(grid, "[data-hand=ventaglio]")
    end
  end

  describe "tavolo" do
    test "shows the score, the briscola and how far the hand has got",
         %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/prototipi/tavolo?mano=ventaglio")

      assert html =~ "NOI"
      assert html =~ "24"
      assert html =~ "Coppe"
      assert html =~ "6/10"
    end

    test "picking a card selects it and leaves the others unselected",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prototipi/tavolo?mano=ventaglio")

      view
      |> element("#tavolo-verticale button[phx-value-index='3']")
      |> render_click()

      assert has_element?(
               view,
               "#tavolo-verticale button[phx-value-index='3'][aria-pressed=true]"
             )

      assert has_element?(
               view,
               "#tavolo-verticale button[phx-value-index='6'][aria-pressed=false]"
             )
    end

    test "cards out of play this trick cannot be picked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prototipi/tavolo?mano=ventaglio")

      assert has_element?(view, "#tavolo-verticale button[phx-value-index='9'][disabled]")
      refute has_element?(view, "#tavolo-verticale button[phx-value-index='7'][disabled]")
    end

    test "serves both orientations, each with the variant's hand", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prototipi/tavolo?mano=griglia")

      assert has_element?(view, "#tavolo-verticale [data-hand=griglia]")
      assert has_element?(view, "#tavolo-orizzontale [data-hand=griglia]")
      refute has_element?(view, "[data-hand=ventaglio]")
    end
  end
end
