defmodule Mastery.Core.Template do
  defstruct ~w[name category instructions raw compiled generators checker]a

  @type t :: %__MODULE__{
          name: atom(),
          category: atom(),
          instructions: String.t(),
          raw: String.t(),
          compiled: Macro.t(),
          generators: %{substitution: list() | function()},
          checker: (String.t(), String.t() -> boolean())
        }

  def new(fields) do
    fields
    |> Keyword.fetch!(:raw)
    |> then(&struct!(__MODULE__, Keyword.put(fields, :compiled, EEx.compile_string(&1))))
  end
end
