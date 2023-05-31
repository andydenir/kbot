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


*****************************************************************************************************************************

Coding Session Makefile+Dockerfile

Практическая работа

Подготовим два важных файла для последующей автоматизации цикла CI/CD. Makefile для бинарного файла и Dockerfile для контейнер имеджа.
Начнем с Makefile.

Утилита MAKE, это утилита, что руководит генерацией бинарных и других файлов программы из исходного кода. Мы рассмотрим простой make-файл, который описывает, как скомпилировать kbot, а потом добавим еще Docker-файл и автоматизируем build и push контейнер имеджа.

Добавим файл с названием Makefile в корневую директорию проекта.
Для начала добавим в файл все команды, которые мы уже использовали и обозначим их отдельными блоками.
Эти блоки описывают правила, как именно сделать таргет или целевой файл.
Например "go format" будет обозначен правилом с таргетом "format"

//в консоли
kbot>gofmt -s -w ./

//в мэйк
format:
    gofmt -s -w ./
    
Проверим в консоли:

kbot>make format

в выводе получим исходник команды:

gofmt -s -w ./

Далее сделаем таргет "build".
Скопируем знакомую уже нам команду "go build" прямо с параметрами:
// в мэйк
build:
    go build -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.2
    
Далее ее оптимизируем: добавим опцию -v для получения расширенной информации и опцию -о с указанием исходного файла "kbot".
Версию мы вынесем в отдельную переменную среды:

//в мэйк
build:
    go build -v -o -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=${VERSION}
    
После этого на первой строке мэйк-файла отдельно выносим переменную version, данные для которой мы будем брать автоматически из команды "git describe" с опцией "--tags":

//в мэйк
VERSION:

//в консоли
git describe --tags

Мне выдало ошибку о том, что неоткуда брать данные. Я пытался склонировать всесь проект kbot ииз репозитория GitHub, но не получилось - выдало, что такой проект уже существует.
Я удилил весь проект командой "sudo rm -r kbot" и тогда клонирование получилось.
Снова ввел команду "git describe --tags", выдало, что "fatal: No names found, cannot describe anything".
Для начала я дал команду "git init" и мне выдало, что "Reinitialized existing Git repository in /home/chulogato171/kbot/.git/".
Ок, пытаюсь снова вытащить версию. Голяк.
Тогда я прост задал версию вручную:

//в консоли
kbot>git tag v1.0.1
kbot>git describe --tags
v1.0.1

Замечательно, команда сработала. Идем дальше.

"build info", то есть, уникальная информация, а именно, сокращенный хэш коммита возьмем с помощью команды "git rev-parse". Это внутренняя утилита для разбора ревизий и объектов для других команд. Возвращает короткий формат хэша последнего коммита.

kbot>git describe --tags --abbrev=0
v1.0.1
kbot>git rev-parse HEAD
9de38a37092cc748631ad071480c939a62ffe227
kbot>git rev-parse --short HEAD
9de38a3

Скомпонуем значение переменной "VERSION" используя обе команды. Обратите внимание, что формат команды в круглых скобках с предыдущим знаком переменной и указанием "shell", то есть именно исполнение действия.
Это специфично для Makefile:

//в мэйк
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

Проверяем:

//в консоли
kbot>make build
go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.1-2da7f90
github.com/andydenir/kbot

Правила в середине мэйкфайла можно объединять и выставлять приоритеты выполнения. Например, выполнить форматирование перед шагом билда.
Для этого в мэйкфайле допишем "format" после "build:"

build: format
	go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=${VERSION}
	
В выводе получаем:
gofmt -s -w ./
go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.1-2da7f90

Дальше посмотрим, как настроить команду "build" для поддержки разных платформ.
Укажем Target OS и архитектуру:

//в мэйк
build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=${VERSION}
	
Архитектуру платформы можно определять автоматически разными способами.

//в консоли
kbot>make build
gofmt -s -w ./
CGO_ENABLED=0 GOOS= GOARCH=amd64 go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=v1.0.1-2da7f90

Добавим еще два блока правил "lint" и "test" ниже, под правилом "format":

lint:
	golint

test:
	go test -v
	
"golint" отличается от "gofmt": последний переформатирует исходный код "go", в то время как "golint" выводит ошибки стиля.

Таргет "test" - команда, что автоматизирует выполнение тестирования "go-пакетов".

В конце (файла) добавим правило "clean": в данном случае для автоматического удаления файлов, которые образовались, как результат выполнения других таргетов

clean:
	rm -rf kbot
	
Проверяем работу только что добавленных правил:

kbot>make lint
golint
kbot>make test
go test -v
?       github.com/andydenir/kbot       [no test files]
kbot>make clean
rm -rf kbot

Например, нам нужен бинарный файл только на время выполнения, а не в истории коммитов.
Таким образом мы оптимизировали некоторые команды, что использовали мануально.
А главное, Makefile очень удобное и общепринятое место, где каждый сможет найти полезную информацию о правилах билда проекта.

На следующем шаге создадим Dockerfile и автоматизируем "build" и "push" имеджа.
Мы выберем базовый имэдж, как официальный Golang - это будет шаг "build":

FROM golang:1.20 as build

Далее укажем рабочую директорию:

WORKDIR /go/src/app

В инструкцию "COPY" скопируем выходной код к билд-контексту:

COPY . .

Следующей командой выполним "go get" для установления зависимостей:

RUN go get

И следующая команда "make build" для сборки бинарного файла:

RUN make build

Кстати, команду "go get" нужно переместить в Makefile, так как здесь она точно лишняя.

С целью оптимизации, у нас multy stage формат докер-файла.

FROM scratch
WORKDIR /

Мы сделаем "COPY" артефакта из билдера.

COPY --from=build /go/src/app/kbot .

А второй инструкцией "COPY" загрузим из официального "alpine" корневой сертификат для поддержки https.
Без этого "tls" не поднимется.

COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

"ENTRYPOINT" обозначим, как запуск бинарника "kbot" без параметров:

ENTRYPOINT ["./kbot"]


По итогу:

********************************************************
В "DOCKERFILE":

FROM golang:1.20 as build

WORKDIR /go/src/app
COPY . .
RUN make build
RUN go get

FROM scratch
WORKDIR /
COPY --from=build /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]

*******************************************************
И, в "MAKEFILE":

VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

build: format
	CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X="github.com/andydenir/kbot/cmd.appVersion=${VERSION}

clean:
	rm -rf kbot

********************************************************

Проверим Dockerfile запустив команду "docker build ." в корне проекта.
Мы можем увидеть, как выполняются указанные в файле инструкции.
А теперь запустим контейнер командой "docker run" с указанием хэша имеджа:

docker run sha256:a9cd6d37e60ae0ea1e3f1d6aaf7704259ac3e23645d51abc17a494420d22f778

НО!!! Получаю ошибку: 

exec ./kbot: no such file or directory

Долго бился над этой проблемой, перебирая все возможные варианты указания пути для бинарного файла, типа:

ENTRYPOINT ["./kbot"]
ENTRYPOINT ["/kbot"]
ENTRYPOINT ["kbot"]
ENTRYPOINT ["workpaces/kbot"]

и так далее...

После того, как написал ментору об ошибке, он ответил: "Denys Vasyliev [ментор] @Andy тут трохи уваги на команду зборки"

Я покопался, сравнил все значения в видео и у себя, изменил единицу на ноль, снова запустил "run" и все пошло, как по маслу!

А все потому. что: "Я, намагаючись знайти іншу помилку трохи раніше змінив значення CGO_ENABLED з нуля на одиницю (дякую Stack Overflow)"

Вот так...

Поэтому в Makefile часть команды "build: format" должна обязательно выгладеть так:

CGO_ENABLED=0

Ноль, а не единица, как я думал ранее!

И еще. В данный момент я не запускал Docker Decktop. И все получилось, хотя ранее мне казалось, что запуская докер в терминале, обязательно нужно запустить локальный докер. Но, нет...

ПОсле того, как закончится билд и у нас появится хэш к образу, вводим команду "docker run" с опциями: дополнение "version" вернет нам номер версии, а дополнение "start" напомнит о токене. 

kbot>docker run sha256:a9cd6d37e60ae0ea1e3f1d6aaf7704259ac3e23645d51abc17a494420d22f778 version
v1.0.1-2da7f90
kbot>docker run sha256:1cfbb6c7fa01ad228b5e569f95e1705eb36838ceb979801809c8ce3dbe587fa2 start
kbot v1.0.1-2da7f90 started2023/05/29 07:50:31 Please check TELE_TOKEN env variable. telegram: Not Found (404)

ИНТЕГРАЦИЯ

Далее добавим правило Dockerfile для сборки имэджа в Makefile
Создадим еще одну переменную "APP" для автоматического назначения полного имени контейнер-имэджа на базе названия гит-репозитория. Для этого воспользуемся командой "git remote get-url origin" и втроенной командой "basename"

//в консоли
kbot>git remote get-url origin
https://github.com/andydenir/kbot

kbot>basename $(git remote get-url origin)
kbot

//в мэйк
APP=$(shell basename $(shell git remote get-url origin))

Значение "REGISTRY" это мой DockerHub аккаунт

//в мэйк
REGISTRY=chulogato171

и добавим значение для "TARGETOS":

//в мэйк
TARGETOS=linux

В Makefile нужно внести инструкцию для "get" и добавил ее для "target build"
(*** в Dockerfile нужно убрать команду "RUN go get", поскольку она теперь перенесена в Makefile!)

//в мэйк
get:
	go get
	
И немного изменим значение "build:" - добавим команду "get" к значению "build: format":

//в мэйк
build: format get

Создадим новый таргет с именем "image" ждя команды "docker build".
Опция "tag" будет автоматизирована с помощью переменных "REGISRTY", "APP", "VERSION" "TARGETARCH".

//в мэйк после таргета "build"
image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

Выставим значение для "TARGETARCH" по умолчанию, как "arm64":

//в мэйк после таргета "TARGETOS=linux"
TARGETARCH=arm64

То же самое сделаем для таргета "push":

//в мэйк после таргета "image"
push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

И проверим, как работает имэдж:

//в консоли
kbot>make image

Docker сбилдает для нас контейнер-имэдж:

 => exporting to image                                                                                                                                                                              0.1s
 => => exporting layers                                                                                                                                                                             0.0s
 => => writing image sha256:1cfbb6c7fa01ad228b5e569f95e1705eb36838ceb979801809c8ce3dbe587fa2                                                                                                        0.0s 
 => => naming to docker.io/chulogato171/kbot:v1.0.1-2da7f90-arm64  
 
Docker сбилдает для нас контейнер-имэдж и далее запушим образ:
(*** заранее нужно авторизироваться в консоли командой "docker login"!!!)


//в консоли
kbot>make push
docker push chulogato171/kbot:v1.0.1-2da7f90-arm64
The push refers to repository [docker.io/chulogato171/kbot]
34af2edcf27f: Pushed 
1f9db18b467c: Pushed 
v1.0.1-2da7f90-arm64: digest: sha256:6045b1c5268545c0997961c29372e3ede6a0ff082e90333130ad248547b93848 size: 737

Протестируем "docker run" с указанием полного тега:

//в консоли
kbot>docker run chulogato171/kbot:v1.0.1-2da7f90-arm64 

Все работает, а работать НЕ ДОЛЖНО!
А все потому, что мы указали переменную по умолчанию для GOARCH в Makefile со значением "arm64", но только в команде "docker build", а бинарник собрался как "amd64".

Поэтому изменим правило для сборки бинарника с автоматической не УКАЗАННУЮ архитектуру 

//в мэйк в строке таргета "build: format get" значение "GOARCH=${shell dpkg --print-architecture}" меняем на "GOARCH=${TARGETARCH}"

И проверим снова, как это работает. Еще раз сбилдаем:

//в консоли
kbot>make build
(должно долго генерировать что-то типа такого:
vendor/golang.org/x/net/http/httpproxy
vendor/golang.org/x/net/http2/hpack
net/http/internal
net/http/internal/ascii
regexp/syntax
net/http/httptrace
regexp
net/http
gopkg.in/telebot.v3
github.com/andydenir/kbot/cmd
github.com/andydenir/kbot)

И запустим программу:

//в консоли
kbot>./kbot
bash: ./kbot: cannot execute binary file: Exec format error

И сейчас получили ошибку "Exec format error, то есть ошибку формата исполнения.
Это нормально!
Команда "file .kbot" подтвердит нам, что бинарный формат у нас именно "arm64" (см ниже "ARM aarch64"):

//в консоли
kbot>file ./kbot
./kbot: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, Go BuildID=jqKD9HTR_-QI2YptXmtg/DF5T4g8rQoFr2YuaoVNp/KV7ZHqAq8gzeA0Yb9qHu/usZTtQ_dqfmRunUkIX_x, with debug_info, not stripped

А мы находимся на архитектуре "amd64" - см. в мэйк значение TARGETARCH=arm64

В конце нужно не забыть сделать коммит и тег для сохранения изменений в коде:

git add .
git status
git commit
git status
git push