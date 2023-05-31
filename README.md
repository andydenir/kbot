# kbot

Telegram bot
Ссылка: https://t.me/andydenir_bot

Алгоритм создания проекта

Импорт библиотеки Cobra
"github.com/spf13/cobra"
Импорт библиотеки Telebot
telebot "gopkg.in/telebot.v3"

Задаем значение для переменной
TeleToken = os.Getenv("TELE_TOKEN")

Добавляем код в функцию Run:
вывод версии бота в строковом формате
fmt.Printf("kbot %s started", appVersion)
И блок инициализации функции kbot
в котором указаны все требуемые параметры
kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "", 
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second}
			
Добавляем код обработки ошибок
if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable. %s", err)
			return
			
Добавляем код обработки новых сообщений. Нам будут возвращены метаданные
+ само сообщение и код завершения функции.
		kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			log.Print(m.Message().Payload, m.Text())

Активируем функцию: kbot.Start()

Тестируем.

Команда $ gofmt -s -w ./ форматирует программу для go
(табуляция, отступы и т.д.)

Команда $ go get для запуска установки пакетов и зависимомтей

И когда пакет телебот установлен запускаем билд программы:
$ go build -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.1
с версией v1.0.1

В результате у нас в проекте появляется бинарный файл,
который мы запускаем пока без каких-либо параметров
./kbot
Добавляем алиас для команды ./kbot (альтернативную команду для старта)
Aliases: []string{"start"}
Снова запускаем билд
$ go build -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.1
и тестируем командой $ ./kbot start


Подготавливаем бот.
Открываем BotFather в телеграмме, нажимаем /newbot - create a new bot,
вводим название аккаунта "kbot", имя и получаем токен для API 
и ссылку на канал созданного бота.

Далее безопасно изменяем среду, чтобы не осталось
информации в логах терминала командой read -s TELE_TOKEN и 
в строке запроса данных вставляем скопированный токен.
Нажимаем enter.

Затем проверяем значение переменной с помощью команды echo TELE_TOKEN

Делаем экспорт изменений export TELE_TOKEN и запускаем программу $ ./kbot start

Переходим в чат "kbot" и нажимаем кнопку "start".
После этого в логах мы увидим, что бот получил нашу команду.
codespace:/workspaces/kbot> ./kbot start
kbot v1.0.1 started
2023/05/05 08:38:47 /start


Добавим еще код в Payload:
переменную "payload" со значением отправки сообщения
payload := m.Message().Payload

			switch payload {
			case "hello":
				err = m.Send(fmt.Sprintf("Hello! I am kbot %s", appVersion))
				
			}
			
Собираем патч-версию v1.0.2 и проверим, как это работает:
go build -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.2
./kbot start
В боте вызываем команду /start hello
и в терминале получаем лог с новой версией:
codespace:/workspaces/kbot> ./kbot start
kbot v1.0.2 started2023/05/05 08:45:40 start hello
2023/05/05 08:46:20 hello/start hello

Делаем commit изменений кода и пушим в репозиторий github
<<<<<<< HEAD
=======

>>>>>>> origin


