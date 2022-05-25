# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса, в идеале весь наш функционал
# (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: она будет создана на фабрике заново для каждого блока it,
  # где она вызывается.
  let(:game_question) do
    FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  # Группа тестов на игровое состояние объекта вопроса
  context 'game status' do
    # Тест на правильную генерацию хэша с вариантами
    describe '#variants' do
      it 'should be return correct hash with answers variants' do
        expect(game_question.variants).to eq(
          'a' => game_question.question.answer2,
          'b' => game_question.question.answer1,
          'c' => game_question.question.answer4,
          'd' => game_question.question.answer3
        )
      end
    end

    describe '#answer_correct?' do
      it 'should be truthy when answer b' do
        expect(game_question.answer_correct?('b')).to be_truthy
      end
    end

    describe '#delegate lvl' do
      it 'should return correct question.level' do
        expect(game_question.level).to eq(game_question.question.level)
      end
    end

    describe '#delegate txt' do
      it 'should return correct questions.text' do
        expect(game_question.text).to eq(game_question.question.text)
      end
    end

    describe '#correct_answer_key' do
      it 'should return correct key' do
        expect(game_question.correct_answer_key).to eq('b')
      end
    end
  end
end
