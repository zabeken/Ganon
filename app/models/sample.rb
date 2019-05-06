class Sample < ApplicationRecord
    has_many_attached :samplefiles
    # TODO: ZIPファイルをくっつける has_one_attached :zipfile
end
