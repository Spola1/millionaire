# (c) goodprogrammer.ru

require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для игрового контроллера
# Самые важные здесь тесты:
#   1. на авторизацию (чтобы к чужим юзерам не утекли не их данные)
#   2. на четкое выполнение самых важных сценариев (требований) приложения
#   3. на передачу граничных/неправильных данных в попытке сломать контроллер
#
RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { create(:user) }
  # админ
  let(:admin) { create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  describe '#show' do
    # из экшена show анона посылаем
    context 'when user is anonymous' do
      # вызываем экшен
      before do
        get :show, id: game_w_questions.id
      end
      # проверяем ответ
      it 'should return a non-200 status' do
        expect(response.status).not_to eq(200) # статус не 200 ОК
      end

      it 'should redirect to devise new_user_session_path' do
        expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      end

      it 'flash alert' do
        expect(flash[:alert]).to be # во flash должен быть прописана ошибка
      end
    end
  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  describe '#create' do
    context 'when user is logged in' do
      # перед каждым тестом в группе
      before do
        sign_in user
        generate_questions(15)
        post :create
      end

      let!(:game) { assigns(:game) }

      # проверяем состояние этой игры
      context 'when user not have unfinished game' do
        it 'create not finished game' do
          expect(game.finished?).to be false
        end

        it 'create game for current user' do
          expect(game.user).to eq(user)
        end

        # и редирект на страницу этой игры
        it 'redirect to game path' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'flash notice' do
          expect(flash[:notice]).to be
        end
      end

      context 'when user have unfinished game' do
        before do
          expect(game.finished?).to be false

          post :create
        end

        it 'redirect to unfinished game' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'does not create new game' do
          expect { post :create }.to change(Game, :count).by(0)
        end

        it 'flash alert' do
          expect(flash[:alert]).to be
        end
      end
    end

    context 'when user is anonymous' do
      # вызываем экшен
      before do
        post :create
      end
      # проверяем ответ
      it 'should return a non-200 status' do
        expect(response.status).not_to eq(200) # статус не 200 ОК
      end

      it 'should redirect to devise new_user_session_path' do
        expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      end

      it 'flash alert' do
        expect(flash[:alert]).to be # во flash должен быть прописана ошибка
      end
    end
  end

  describe '#answer' do
    context 'when user is logged in' do
      before do
        sign_in user
      end

      context 'when game is not finished' do
        before do
          put :answer, id: game_w_questions.id,
          letter: answer_key
        end

        context 'when answer correct' do
          let!(:answer_key) { game_w_questions.current_game_question.correct_answer_key }
          let!(:game) { assigns(:game) }

          it 'continues game' do
            expect(game.finished?).to be false
          end

          it 'game level increases' do
            expect(game.current_level).to be > 0
          end

          it 'redirects to game path' do
            expect(response).to redirect_to(game_path(game))
          end

          it 'has no flash messages' do
            expect(flash.empty?).to be true
          end
        end

        context 'when answer is not correct' do
          let!(:answer_key) { (%w[a b c d].grep_v game_w_questions.current_game_question.correct_answer_key).sample }
          let!(:game) { assigns(:game) }

          it 'finish game' do
            expect(game.finished?).to be true
          end

          it 'finish game with status :fail' do
            expect(game.status).to eq(:fail)
          end

          it 'game level does not increase' do
            expect(game.current_level).to be 0
          end

          it 'redirects to user path' do
            expect(response).to redirect_to(user_path(user))
          end

          it 'flash alert' do
            expect(flash[:alert]).to be
          end
        end
      end
    end

    context 'when user is anonymous' do
      # вызываем экшен
      before do
        put :answer, id: game_w_questions.id,
        letter: game_w_questions.current_game_question.correct_answer_key
      end
      # проверяем ответ
      it 'should return a non-200 status' do
        expect(response.status).not_to eq(200) # статус не 200 ОК
      end

      it 'should redirect to devise new_user_session_path' do
        expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      end

      it 'flash alert' do
        expect(flash[:alert]).to be # во flash должен быть прописана ошибка
      end
    end
  end

  describe '#take_money' do
    context 'when user is logged in' do
      context 'when game is not finished' do
        before do
          sign_in user
          game_w_questions.update_attribute(:current_level, 2)
          put :take_money, id: game_w_questions.id
        end
        let!(:game) { assigns(:game) }

        it 'finished game' do
          expect(game.finished?).to be true
        end

        it 'get prize for 2 lvl' do
          expect(game.prize).to eq(Game::PRIZES[1])
        end

        it 'add prize to user balance' do
          user.reload
          expect(user.balance).to eq(Game::PRIZES[1])
        end

        it 'redirect to user page' do
          expect(response).to redirect_to(user_path(user))
        end

        it 'flash warning' do
          expect(flash[:warning]).to be
        end
      end
    end

    context 'when user is anonymous' do
      # вызываем экшен
      before do
        put :take_money, id: game_w_questions.id
      end
      # проверяем ответ
      it 'should return a non-200 status' do
        expect(response.status).not_to eq(200) # статус не 200 ОК
      end

      it 'should redirect to devise new_user_session_path' do
        expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      end

      it 'flash alert' do
        expect(flash[:alert]).to be # во flash должен быть прописана ошибка
      end
    end
  end
end
