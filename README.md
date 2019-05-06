# 開発環境

## 事前の環境作成

DockerとDockerComposeをインストールします

~~~
sudo apt install docker
sudo apt install docker-compose
~~~

※Windows10の場合は下記参照

https://qiita.com/koinori/items/78a946fc74452af9afba

Dockerをsudoなしで使えるようにしておきます

https://qiita.com/DQNEO/items/da5df074c48b012152ee

```bash
# dockerグループがなければ作る
sudo groupadd docker
# 現行ユーザをdockerグループに所属させる
sudo gpasswd -a $USER docker
# dockerデーモンを再起動する
sudo systemctl restart docker
# exitして再ログインすると反映される。
exit
```

ssh関連の設定も必要なのでSSHの設定をしとく

https://qiita.com/knife0125/items/50b80ad45d21ddec61a9


## Docker開発環境の作成

ネタもと

https://qiita.com/kawasin73/items/b8b092e9b763387c6ba8

### 導入

作業用のディレクトリを作成し、テンプレートをダウンロード（例：timelineプロジェクト）

```bash
mkdir timeline
cd timeline
git clone https://github.com/kawasin73/rails_docker_template .
```

使いたいrails と Rubyのバージョンに合わせてブランチをチェックアウトする。

ruby-2.6.2-rails-5.2.2.1-webpackがおすすめ。

```bash
git checkout origin/base/ruby-2.6.2-rails-5.2.2.1-webpack
git branch -d master && git checkout -b master
```

Gemfileを書き換え.必要なGemを入れる.

webpack=react→webpack=vueに変更

```Script\init
docker-compose run --rm rails bundle exec rails new . --force --database=postgresql --skip-turbolinks --skip-git --skip-test --webpack=vue
```

初期ビルド実行

```bash
script/init && script/bootstrap
```

### 問題がでます

#### 問題点1

エラーが出ている。

```bash
Bundle complete! 14 Gemfile dependencies, 66 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.
         run  bundle exec spring binstub --all
* bin/rake: spring inserted
* bin/rails: spring inserted
cp: 'config/database.yml' を削除できません: 許可がありません
```

#### 問題点2

root オーナーになっているので、変更が必要

```
ken@Negro ~/pro/timeline $ ls -la
合計 212
drwxr-xr-x 16 ken  ken  4096  3月 21 11:37 .
drwxr-xr-x  5 ken  ken  4096  3月 21 11:06 ..
drwxr-xr-x  2 ken  ken  4096  3月 21 11:13 .circleci
-rw-r--r--  1 ken  ken    97  3月 21 11:36 .env.dev
-rw-r--r--  1 ken  ken    97  3月 21 11:13 .env.dev.sample
drwxr-xr-x  8 ken  ken  4096  3月 21 11:38 .git
-rw-r--r--  1 ken  ken   213  3月 21 11:37 .gitignore
-rw-r--r--  1 root root   10  3月 21 11:37 .ruby-version
-rw-r--r--  1 ken  ken   982  3月 21 11:13 Dockerfile.dev
-rw-r--r--  1 ken  ken  1847  3月 21 11:37 Gemfile
-rw-r--r--  1 root root 4599  3月 21 11:38 Gemfile.lock
-rw-r--r--  1 ken  ken   374  3月 21 11:37 README.md
-rw-r--r--  1 root root  227  3月 21 11:37 Rakefile
drwxr-xr-x 10 root root 4096  3月 21 11:37 app
drwxr-xr-x  2 root root 4096  3月 21 11:38 bin
drwxr-xr-x  5 root root 4096  3月 21 11:37 config
-rw-r--r--  1 root root  130  3月 21 11:37 config.ru
drwxr-xr-x  2 root root 4096  3月 21 11:37 db
-rw-r--r--  1 ken  ken   662  3月 21 11:13 docker-compose.yml
drwxr-xr-x  4 root root 4096  3月 21 11:37 lib
drwxr-xr-x  2 root root 4096  3月 21 11:37 log
-rw-r--r--  1 root root   61  3月 21 11:37 package.json
drwxr-xr-x  2 root root 4096  3月 21 11:37 public
drwxr-xr-x  2 ken  ken  4096  3月 21 11:13 script
drwxr-xr-x  2 root root 4096  3月 21 11:37 storage
drwxr-xr-x  2 ken  ken  4096  3月 21 11:13 template
drwxr-xr-x  4 root root 4096  3月 21 11:37 tmp
drwxr-xr-x  2 root root 4096  3月 21 11:37 vendor
```

### 解決

database.ymlのコピーでエラーが出ている問題は、下記のコマンドが失敗してる。

```bash
cp -f template/database.yml config/database.yml
```

問題点2によって問題点1が引き起こされているので、chownコマンドでオーナーを自分に変更した後、失敗していたコマンドを再実行してdatabase.ymlをコピーする

```bash
sudo chown -R ken:ken .
cp -f template/database.yml config/database.yml
```

### 起動と確認

起動と確認。

```
docker-compose up -d
# access to http://localhost:3000
```

Logフォルダを見てエラーが出てなければOK。

```bash
docker-compose exec rails bash
```

remoteリポジトリをgithubに変更してpush

```bash
git remote set-url origin git@github.com:xex-ken-xex/timeline.git
git push -u origin master
```


# リポジトリから新しく開発環境を設定する

事前の環境作成は終わらせておくこと

## git からcloneして、コンテナを作る

```bash
git clone git@github.com:xex-ken-xex/timeline.git
cd timeline
script/bootstrap
# initialize credentials.yml.enc (必要なら）
#docker-compose run --rm rails bin/rails credentials:edit

docker-compose up -d
docker-compose exec rails bash
# access to http://localhost:3000
```
## script/bootstrap でエラーがでたら

以下を再度実行してみる

```
docker-compose run --rm rails bin/yarn install
script/bootstrap
```

## 開発中のあれ

ホスト側でこんな感じで実行する


### rails コンテナ

```bash
docker-compose exec rails bin/rails generate scaffold user name:string age:integer
```

```bash
docker-compose exec rails bin/rails db:migrate
```

### webpack コンテナ

```bash
docker-compose exec webpack yarn add vue-turbolinks
```

https://blog.freedom-man.com/ruby-docker-bundler/ をみたところ

bundle installはちょっとクセがあるっぽい。今の所問題ないけど。

```bash
docker-compose exec rails bundle install
```

