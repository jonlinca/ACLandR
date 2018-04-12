predict_numberOfWins <- function(solo_KillDeathRatio, solo_TimeSurvived, solo_RoundsPlayed,
                         solo_Top10s, solo_Top10Ratio, solo_Rating, 
                         solo_BestRating, solo_DamagePg, solo_HeadshotKillsPg, 
                         solo_HealsPg, solo_KillsPg, solo_MoveDistancePg, 
                         solo_RoadKillsPg, solo_TeamKillsPg, solo_TimeSurvivedPg, 
                         solo_Top10sPg, solo_Kills, solo_Assists, 
                         solo_Suicides, solo_TeamKills, solo_HeadshotKills, 
                         solo_HeadshotKillRatio, solo_VehicleDestroys, solo_RoadKills, 
                         solo_DailyKills, solo_WeeklyKills, solo_RoundMostKills,
                         solo_MaxKillStreaks, solo_Days, solo_LongestTimeSurvived, 
                         solo_MostSurvivalTime, solo_AvgSurvivalTime, solo_WalkDistance, 
                         solo_RideDistance, solo_MoveDistance, solo_AvgWalkDistance, 
                         solo_AvgRideDistance, solo_LongestKill, solo_Heals,
                         solo_Boosts, solo_DamageDealt){
  
  #This function will take in a series of passed variables from ACL, and return a prediction
  
  # Load the tuned model, which our data scientist may provide
  load(file = "F:/ACL Temp/2018-04 ACL and R/ACL/tuned_model.rda")

  # Create a one-row data frame, based on the features we are using to predict
  predictionDataFrame <- c(solo_KillDeathRatio, solo_TimeSurvived, solo_RoundsPlayed,
                           solo_Top10s, solo_Top10Ratio, solo_Rating, 
                           solo_BestRating, solo_DamagePg, solo_HeadshotKillsPg, 
                           solo_HealsPg, solo_KillsPg, solo_MoveDistancePg, 
                           solo_RoadKillsPg, solo_TeamKillsPg, solo_TimeSurvivedPg, 
                           solo_Top10sPg, solo_Kills, solo_Assists, 
                           solo_Suicides, solo_TeamKills, solo_HeadshotKills, 
                           solo_HeadshotKillRatio, solo_VehicleDestroys, solo_RoadKills, 
                           solo_DailyKills, solo_WeeklyKills, solo_RoundMostKills,
                           solo_MaxKillStreaks, solo_Days, solo_LongestTimeSurvived, 
                           solo_MostSurvivalTime, solo_AvgSurvivalTime, solo_WalkDistance, 
                           solo_RideDistance, solo_MoveDistance, solo_AvgWalkDistance, 
                           solo_AvgRideDistance, solo_LongestKill, solo_Heals,
                           solo_Boosts, solo_DamageDealt)
  
  # Loads the libraries you need to create a prediction
  library(caret)
  library(randomForest)
  
  # Make a prediction of the Win Ratio, and return that out of the function
  outcome <- predict(tuned_model$finalModel, predictionDataFrame)
}

#Call the function, based on value inputs from ACL. Save the result - this goes back to ACL
returnToACL <- predict_numberOfWins(value1, value2, value3, value4, 
                                    value5, value6, value7, value8,
                                    value9, value10, value11, value12,
                                    value13, value14, value15, value16,
                                    value17, value18, value19, value20,
                                    value21, value22, value23, value24,
                                    value25, value26, value27, value28,
                                    value29, value30, value31, value32,
                                    value33, value34, value35, value36,
                                    value37, value38, value39, value40,
                                    value41)

