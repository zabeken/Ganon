namespace :compress do
    desc "ダウンロード用にZIPファイルをかためて保持する"
    task zip: :environment do
      Compress::Zip.batch
    end
end
