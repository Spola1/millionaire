require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }
  let(:game_w_questions) do create(:game_with_questions, user: user)
  end

  describe '::create_game_for_user' do
    before do
      generate_questions(60)

      game = nil

      # Создaли игру, обернули в блок, на который накладываем проверки
      expect {
        game = Game.create_game_for_user!(user)
        # Проверка: Game.count изменился на 1 (создали в базе 1 игру)
      }.to change(Game, :count).by(1).and(
        # GameQuestion.count +15
        change(GameQuestion, :count).by(15).and(
          # Game.count не должен измениться
          change(Question, :count).by(0)
        )
      )
    end

    let(:game) { Game.create_game_for_user!(user) }

    context 'check status, fields and correctness of the array of game questions' do
      it 'should create game with specific user' do
        expect(game.user).to eq(user)
      end

      it 'should create game with status :in progress' do
        expect(game.status).to eq(:in_progress)
      end

      it 'should create game with 15 questions' do
        expect(game.game_questions.size).to eq(15)
      end

      it 'should create a game with levels from 0 to 14' do
        expect(game.game_questions.map(&:level)).to eq (0..14).to_a
      end
    end
  end

  describe '#take_money!' do
    before do
      game_w_questions.take_money!
    end

    context 'when second question answered' do
      let!(:game_w_questions) { create(:game_with_questions, user: user, current_level: 2) }

      it 'should finish game' do
        expect(game_w_questions.finished?).to be true
      end

      it 'should finish with status money' do
        expect(game_w_questions.status).to eq :money
      end

      it 'should get prize for second question' do
        expect(game_w_questions.prize).to eq(Game::PRIZES[1])
      end
    end
  end

  describe '#status' do
    context 'when game finished' do
      before do
        game_w_questions.finished_at = Time.now
        expect(game_w_questions.finished?).to be true
      end

      it 'should return won' do
        game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
        expect(game_w_questions.status).to eq(:won)
      end

      it 'should return fail' do
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:fail)
      end

      it 'should return timeout' do
        game_w_questions.created_at = 1.hour.ago
        game_w_questions.is_failed = true
        expect(game_w_questions.status).to eq(:timeout)
      end

      it 'should return money' do
        expect(game_w_questions.status).to eq(:money)
      end
    end
  end

  describe '#current_game_question' do
    let!(:game_w_questions) { create(:game_with_questions, current_level: 4) }
    it 'should return current game question' do
      expect(game_w_questions.current_game_question.level).to eq(4)
    end
  end

  describe '#previous_level' do
    let!(:game_w_questions) { create(:game_with_questions, current_level: 0) }

    it 'should return -1' do
      expect(game_w_questions.previous_level).to eq(-1)
    end
  end

  describe '#answer_current_question!' do
    before do
      game_w_questions.answer_current_question!(answer_key)
    end

    context 'when answer correct' do
      let!(:answer_key) { game_w_questions.current_game_question.correct_answer_key }

      context 'when question last' do
        let!(:game_w_questions) { create(:game_with_questions, user: user, current_level: 14) }

        it 'should finish game with status won' do
          expect(game_w_questions.status).to eq :won
        end

        it 'should return the final amount of money' do
          expect(game_w_questions.prize).to eq(Game::PRIZES[14])
        end
      end

      context 'when time over' do
        let!(:game_w_questions) { create(:game_with_questions, user: user, created_at: 36.minutes.ago) }

        it 'should finish game' do
          expect(game_w_questions.finished?).to be true
        end

        it 'should finish game with status timeout' do
          expect(game_w_questions.status).to eq(:timeout)
        end
      end
    end

    context 'when answer wrong' do
      let!(:answer_key) { (%w[a b c d].grep_v (game_w_questions.current_game_question.correct_answer_key)).sample }

      it 'should finish game' do
        expect(game_w_questions.finished?).to be true
      end

      it 'should finish game with status fail' do
        expect(game_w_questions.status).to eq :fail
      end
    end
  end
end
