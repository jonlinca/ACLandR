## Background
So you know how to use ACL and even got your feet wet with R and Machine Learning. How can you apply what you’ve learned here to your strong data pipeline and analytic skills in ACL Analytics (or better yet, ACL Analytics Exchange)?

We’re going to use to use ACL to “deploy” our model into production. This means that we’ve already trained a machine learning model we are happy with, to make predictions on incoming data. 

Why is this important? You may be working with Data Scientists who can ‘train’ models for you but need to run it in your own ACL Analytics environment. You can take a trained model and call it directly from ACL, while leveraging the expertise that comes from your data scientist.

This is my first attempt at writing a tutorial, let alone on such a crazy fun topic and mixing up my two favorite analysis platforms. If you have any suggestions for me, please let me know!

Special thanks to [Ruben Rivero from ACL](https://www.acl.com/), who helped me when I ran out of fuel dealing with errors, and [Rachael Tatman's excellent tutorial](https://www.kaggle.com/rtatman/picking-the-best-model-with-caret) to which I build this extension off of.

## Pre-requisites
The below extended tutorial below actually revolves around the output from Rachael Tatman’s tutorial, https://www.kaggle.com/rtatman/picking-the-best-model-with-caret, and assumes that you have executed this tutorial already from start to finish.

This tutorial specifically focuses on the **deployment** of a model. The entire universe of using R to clean data, create features, create a model, train a model, training vs. test data, understanding over/under fitting etc is at least a week long endeavor in itself. If would like to learn how to do those above things, consider trying out https://www.kaggle.com/learn/r. 

I would highly suggest you also install R Studio, and have the latest version of ACL Analytics (this tutorial tested on ACL Analytics 13.0.3). 

## Deploying your model
Rachael’s tutorial concludes with a **trained model** that predicts how often a player will win in a solo match of the video game PLAYERUNKNOWN’S BATTLEGROUNDS. This is a **regression** problem, which gives us a continuous number output. This is different than a classification problem, which is discrete classes leading to a yes/no, true/false, or apple-orange-pineapple outcome. This model that we will leverage called the *tuned_model* within R, which should help predict the field *solo_WinRatio*.

We know that we need to get R to return a number as an output to ACL. This leads us to looking up ACL’s [RNUMERIC() function](https://enablement.acl.com/helpdocs/analytics/13/scripting-guide/en-us/Content/lang_ref/functions/r_rnumeric.htm), which will give us a number that we can use in our analysis. Our goal is to use this function to forecast a number, based on the data we give it.

```
RNUMERIC(rScript|rCode, decimals <,field|value <,...n>>)
```

The RNUMERIC() function calls for an “rScript” or “rCode”. Our R script should take an input (aka the predictor variables), call the model, make a prediction, and return it back to ACL for display. Lastly, the function need to pass any number of ‘values’ to R, which will come from each record and data field in each column.

## Instructions
### Step 1: Within R, Save the model
Before you start, ensure that the [Kaggle tutorial](https://www.kaggle.com/rtatman/picking-the-best-model-with-caret) has been ran.
At the conclusion of the tutorial, the model has already been trained, but hasn't been saved yet for long-term keeping. We can export the “trained” model from R so we can reuse it elsewhere.

```
save(tuned_model, file="tuned_model.rda")
```

As we are using ACL Analytics to create our predictions, we can also export the testing data set from R, which we will load into ACL:

```
write.csv(testing, file = "testing.csv")
```

### Step 2: Within ACL Analytics, Import testing data set
We will import the testing.csv file:

```
IMPORT DELIMITED TO A00_TestingDataset " A00_TestingDataset.fil" FROM "testing.csv" 0 SEPARATOR "," QUALIFIER '"' CONSECUTIVE STARTLINE 1 KEEPTITLE CRCLEAR LFCLEAR ALLFIELDS
```

You should end up with 70,317 records, which is the same number of records in the testing data set in R.

There are 41 columns used for our model (note that the column *solo_WinRatio* is the predictor, so its not included in the prediction and is not counted). In order to make a prediction, our model needs **exactly** the same number of columns as it used in training - in this case, all 41 columns. You will want to pass each one of these into a R function, that you specifically use to return a prediction.

Take some time to inspect the data – you will want to understand what the expected result is.

### Step 3: Within R, create the function that ACL will use to call for a prediction

We need to create a function that returns a numeric value, which is the prediction. We must use the same columns that were used to create the model – in this case, all 41 columns. 

Create a Rscript called “A02_PredictModel.R”. 

The below “predict_numberOfWins” function takes in each value as an argument, and at the same time, gives it a variable name which should map to the column we expect to pass it. It then loads the saved model, creates a one-row data frame for prediction, loads the required libraries. Finally, in one simple line, creates a prediction.

```
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
  load(file = "F:/ACL Temp/2018-04 ACL and R test/ACL/tuned_model.rda")

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
```

Note: For the load function - You need to specify exactly where your model lives. You can improve this script by taking the relative location of the RScript, which is on my to-do list.

Once the function itself has been created, then you create the call to the function within the script itself. The script is expecting a series of values from ACL’s RNumeric function, which comes from ACL in the form of valuex, x being an incremental number.

```
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
```

### Step 4: Within R, test the function

You can confirm that this function works by inputting in manually the first row of the testing dataset. Caution: Do not put this into your A02_PredictModel.R, as ACL will only interpret the last item being returned after an RScript is ran.

```
testRowOne <- predict_numberOfWins(3.14, 18469.14, 17, 4, 23.5, 
  1559.78, 1415.79, 255.36, 0.65, 1.94,
  2.59, 3321.28, 0, 0, 1086.42, 0.24, 44, 1, 0, 0, 11, 0.25,
  0, 0, 13, 19, 13, 1, 14, 1909.66, 1909.66, 1262.83, 28924.31,
  27537.53, 56461.84, 2202.4, 2764.5, 304.87, 33, 29, 4341.06)

testRowOne
```

It should return 16.259, which is the predicted number of wins for this record. You have created the prediction mechanism and the call, which ACL will tap directly into when calling R.

### Step 5: Within ACL Analytics, create the formula that calls the R script

Almost there! Since the R script has been created, all we need to do within ACL is pass the correct values to R. Each column that we specify in ACL will become a valuex that gets passed to R.

```
OPEN A00_TestingDataset

COMMENT
Call the RNUMERIC function, which will call the A02_PredictModel.R script, bring the result back with two decimals, and pass a ton of variables

DEFINE FIELD c_predictedNumberOfWins COMPUTED RNUMERIC("a<-source('A02_PredictModel.R');a[[1]]", 2, solo_KillDeathRatio, solo_TimeSurvived, solo_RoundsPlayed, solo_Top10s, solo_Top10Ratio, solo_Rating, solo_BestRating, solo_DamagePg, solo_HeadshotKillsPg, solo_HealsPg, solo_KillsPg, solo_MoveDistancePg, solo_RoadKillsPg, solo_TeamKillsPg, solo_TimeSurvivedPg, solo_Top10sPg, solo_Kills, solo_Assists, solo_Suicides, solo_TeamKills, solo_HeadshotKills, solo_HeadshotKillRatio, solo_VehicleDestroys, solo_RoadKills, solo_DailyKills, solo_WeeklyKills, solo_RoundMostKills, solo_MaxKillStreaks, solo_Days, solo_LongestTimeSurvived, solo_MostSurvivalTime, solo_AvgSurvivalTime, solo_WalkDistance, solo_RideDistance, solo_MoveDistance, solo_AvgWalkDistance, solo_AvgRideDistance, solo_LongestKill, solo_Heals, solo_Boosts, solo_DamageDealt)
```

In ACL, add the column to the view, and you’ll hopefully see this pop up:
 
![Screenshot of ACL image](ACL%20Screenshot%20of%20Called%20Model.PNG?raw=true)
 
You can see that I specified two decimals, so its rounding my result to 16.26. But its right on the money, and it reflects the R result.

## Troubleshooting
```
The R script is not valid.   Error detail: Error in readChar(con, 5L, useBytes = TRUE) : cannot open the connection
```
Double check your paths in both the R script and ACL code. The full path needs to be stated.

```
Error detail: Error in UseMethod("predict"): no applicable method for 'predict' applied to an object class of "randomForest"
```
The function built within R, when its called, can't see 'predict'. This is because it has not been loaded. Load it within the function with library(randomForest).
