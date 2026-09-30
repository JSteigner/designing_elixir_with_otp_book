defmodule Mastery.Core.Question do
  alias Mastery.Core.Template

  defstruct ~w[asked substitutions template]a

  @type t :: %__MODULE__{
          asked: String.t(),
          template: Template.t(),
          substitutions: [{String.t(), String.t()}]
        }

  def new(%Template{} = template) do
    template.generators
    |> Enum.map(&build_substitution/1)
    |> evaluate(template)
  end

  defp build_substitution({name, choices_or_generator}), do: {name, choose(choices_or_generator)}

  defp choose(choices) when is_list(choices), do: Enum.random(choices)
  defp choose(generator) when is_function(generator), do: generator.()

  defp compile(template, substitutions) do
    template.compiled
    |> Code.eval_quoted(assigns: substitutions)
    |> elem(0)
  end

  defp evaluate(substitutions, template) do
    %__MODULE__{
      asked: compile(template, substitutions),
      substitutions: substitutions,
      template: template
    }
  end
end
