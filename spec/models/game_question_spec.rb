# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса, в идеале весь наш функционал
# (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: она будет создана на фабрике заново для каждого блока it,
  # где она вызывается.
  let(:game_question) do
    create(:game_question, a: 2, b: 1, c: 4, d: 3)
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

    describe '#help_hash' do
      context 'when game created' do
        it 'return empty hash' do
          expect(game_question.help_hash).to eq({})
        end
      end

      context 'when add keys to help hash' do
        before do
          game_question.help_hash[:some_key1] = 'a'
          game_question.help_hash[:some_key2] = 'test'

          expect(game_question.save).to be true
        end
        let!(:game_question_with_hash) { GameQuestion.find(game_question.id) }

        it 'returns hash with added keys' do
          expect(game_question_with_hash.help_hash).to eq({ some_key1: 'a', some_key2: 'test' })
        end
      end
    end

    describe '#add_fifty_fifty' do
      before do
        expect(game_question.help_hash).not_to include(:fifty_fifty)

        game_question.add_fifty_fifty
      end

      it 'add fifty-fifty help to help hash' do
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it 'add fifty-fifty help hash 2 keys' do
        expect(game_question.help_hash[:fifty_fifty].size).to eq 2
      end

      it 'add fifty-fifty help with correct answer key' do
        expect(game_question.help_hash[:fifty_fifty]).to include('b')
      end
    end

    describe '#add_audience_help' do
      before do
        expect(game_question.help_hash).not_to include(:audience_help)

        game_question.add_audience_help
      end

      it 'add audience help to help hash' do
        expect(game_question.help_hash).to include(:audience_help)
      end

      it 'add audience help with 4 keys' do
        ah = game_question.help_hash[:audience_help]
        expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end

    describe '#add_friend_call' do
      before do
        expect(game_question.help_hash).not_to include(:friend_call)

        game_question.add_friend_call
      end

      it 'add friend call to help hash' do
        expect(game_question.help_hash).to include(:friend_call)
      end

      it 'should indlude A B C or D on friend answer' do
        key = game_question.help_hash[:friend_call].last
        expect(%w[A B C D].include?(key)).to be true
      end
    end

    describe '#answer_correct?' do
      it 'should be truthy when answer b' do
        expect(game_question.answer_correct?('b')).to be true
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
