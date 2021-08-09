%% オープンデータの取得
addpath('scripts')
call_center = getCallCenter;
test_count = getTestCount;
patients = getPatients;


%% 公表日ベースの陽性者数取得
% 0人だった日も知りたいので、日付は検査状況から引用する
% -> 休日は検査状況が更新されていないことを考えていなかった。。。
% -> 発生状況の日付も見たほうがよい。
% -> 自動更新ができるようになったらyesterdayを最後の日付にしてもいいかも。
start_date = test_count.InspectionDate(1);
end_date = max(test_count.InspectionDate(end), patients.ConfirmedDate(end));
d = [start_date:end_date]';
confirmedNumberbyDate = zeros(numel(d),1);
for index = 1:numel(d)
    before_generation = max(1, index - 5);
    confirmed_number = length(find(patients.ConfirmedDate==d(index)));
    confirmedNumberbyDate(index) = confirmed_number;
end

%% 各7日間移動平均を計算
% 公表日ベースの陽性者数
confirmednumber_movave = movmean(confirmedNumberbyDate,[6 0]);

%% 簡易実効再生産数の計算
% 7日間移動平均を用いて計算する
% 東洋経済オンラインと同じ数式とする
rt0 = zeros(numel(d),1);
for index = 1:numel(d)
    before_generation = max(1, index - 7);
    beforeval = confirmednumber_movave(before_generation);
    % 0除算対策
    if beforeval == 0
        beforeval = 1;
    end
    rt0(index) = (confirmednumber_movave(index) / beforeval) ^ (5/7);
end


%% 検査数
inspection_movave = movmean(test_count.InspectionNum, [6 0]);
% 検査日ベースの陽性者数
positive_movave = movmean(test_count.Positive, [6 0]);

% 陽性率
positive_rate = test_count.Positive ./ test_count.InspectionNum .* 100;
posrate_movave = movmean(positive_rate, [6 0]);
posrate_movave2 = positive_movave./inspection_movave.*100;