defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Question, Response, Template}

  defstruct title: nil,
            mastery: 3,
            templates: %{},
            used: [],
            current_question: nil,
            last_response: nil,
            record: %{},
            mastered: []

  @type t :: %__MODULE__{
          title: String.t(),
          mastery: integer(),
          current_question: Question.t(),
          last_response: Response.t(),
          templates: %{atom() => [Template.t()]},
          used: [Template.t()],
          mastered: [Template.t()],
          record: %{String.t() => integer()}
        }

  def new(fields), do: struct!(__MODULE__, fields)

  def add_template(quiz, fields) do
    template = Template.new(fields)
    templates = update_in(quiz.templates, [template.category], &add_to_list_or_nil(&1, template))

    %{quiz | templates: templates}
  end

  def select_question(%__MODULE__{templates: t}) when map_size(t) == 0, do: nil

  def select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  def answer_question(quiz, %Response{correct: true} = response) do
    quiz
    |> inc_record()
    |> save_response(response)
    |> then(&maybe_advance(&1, mastered?(&1)))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  def advance(quiz) do
    quiz
    |> move_template(:mastered)
    |> reset_record()
    |> reset_used()
  end

  defp save_response(quiz, response), do: Map.put(quiz, :last_response, response)

  defp mastered?(quiz) do
    score = Map.get(quiz.record, template(quiz).name, 0)
    score == quiz.mastery
  end

  defp inc_record(%{current_question: question} = quiz) do
    quiz.record
    |> Map.update(question.template.name, 1, &(&1 + 1))
    |> then(&Map.put(quiz, :record, &1))
  end

  defp reset_record(%{current_question: question} = quiz) do
    Map.put(quiz, :record, Map.delete(quiz.record, question.template.name))
  end

  defp reset_used(%{current_question: question} = quiz) do
    Map.put(quiz, :used, List.delete(quiz.used, question.template))
  end

  defp maybe_advance(quiz, false = _mastered?), do: quiz
  defp maybe_advance(quiz, true = _mastered?), do: advance(quiz)

  defp add_to_list_or_nil(nil, template), do: [template]
  defp add_to_list_or_nil(templates, template), do: [template | templates]

  defp pick_current_question(quiz) do
    Map.put(quiz, :current_question, select_a_random_question(quiz))
  end

  defp select_a_random_question(quiz) do
    quiz.templates
    |> Enum.random()
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  defp template(quiz), do: quiz.current_question.template

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_templates =
      quiz.templates
      |> Map.fetch!(template.category)
      |> List.delete(template)

    new_templates =
      case Enum.empty?(new_category_templates) do
        true -> Map.delete(quiz.templates, template.category)
        false -> Map.put(quiz.templates, template.category, new_category_templates)
      end

    Map.put(quiz, :templates, new_templates)
  end

  defp add_template_to_field(quiz, field) do
    template = template(quiz)
    list = Map.get(quiz, field)

    Map.put(quiz, field, [template | list])
  end

  defp reset_template_cycle(%__MODULE__{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
    %__MODULE__{
      quiz
      | templates: Enum.group_by(used, fn template -> template.category end),
        used: []
    }
  end

  defp reset_template_cycle(quiz), do: quiz
end
