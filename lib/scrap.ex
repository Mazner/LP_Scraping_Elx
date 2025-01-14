defmodule Scrap do


  def pegar_tokens(string, rank \\ 1) do

    case (length(string) == 0) do
      true ->
        IO.puts("Fim")
      false ->
        [head | tail] = string


        manga_link = "https://mangalivre.net" <> head

        case HTTPoison.get(manga_link) do
          {:ok, %HTTPoison.Response{body: body}} ->
            content = body
            head = Floki.find(content, "head")
            tile_element = Floki.find(head ,"title")
            title_raw = Floki.text(tile_element)

            [title | _trash] = (String.split(title_raw, "(pt-BR)"))

            string_title = "##{rank}: #{title}"

            desc_element = Floki.find(head, "meta[name='description']")
            desc = Floki.attribute(desc_element, "content")
            descricao = Floki.text(desc)
            string_desc = "Descricao: #{descricao}"

            series_info = Floki.find(content, "div.series-info")
            span = Floki.find(series_info, "span.series-author")
            dado = Enum.at(span, 1)
            author_raw = String.trim(String.replace(Floki.text(dado), "\n", ""))

            score_div = Floki.find(body, "div.score-number")
            score = String.trim(Enum.at(String.split(Floki.text(score_div), "\n"), 1))


            IO.puts("\n")
            IO.inspect(string_title)
            IO.inspect(string_desc)
            IO.inspect("Author: #{author_raw}")
            IO.inspect("Nota: #{score}")
            IO.puts("\n")

          end


        pegar_tokens(tail, (rank + 1))
    end



end

  def get_page do

    case HTTPoison.get("https://mangalivre.net/lista-de-mangas/ordenar-por-numero-de-leituras/todos/desde-o-comeco") do
      {:ok, %HTTPoison.Response{body: body}} ->

        div = Floki.find(body, "div.seriesList")
        ul = Floki.find(div, "ul.seriesList")
        anchor = Floki.find(ul, "a.link-block")
        links = Floki.attribute(anchor, "href")


        pegar_tokens(links)
        IO.puts("CHAMADA FINAL")

    end
  end
end
