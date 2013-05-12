Artificial Intelligence - Predicting Diabetes
===========================================

An implementation of the k-Nearest Neighbor and Naïve Bayes algorithms,
and  also the stratified cross validation method, for the purposes of predicting diabetes

### Aim

This study is aimed at creating algorithms that can reliably and accurately predict, based on a limited set of attributes, whether a person is likely to test positive for diabetes. It focuses on the performance of two algorithms I have implemented for performing these predictions: K-Nearest Neighbor and Naive Bayes classification. These algorithms use a method of 10-fold stratified cross-validation for training and evaluation.

Data
-----

### Data Set

The dataset I have been using for testing these classifier algorithms consists of a sample of 768 female patients, all at least 21 years old, and of Pima Indian heritage, who were tested for diabetes. The dataset describes eight separate attributes believed by the World Health Organization to contribute or be correlated with testing positive for diabetes:

1. Number of times pregnant
2. Plasma glucose concentration after 2 hours in an oral glucose tolerance test
3. Diastolic blood pressure (mm Hg)
4. Triceps skin fold thickness (mm)
5. 2-Hour serum insulin (mu U/ml)
6. Body mass index (weight in kg/(height in m)^2)
7. Diabetes pedigree function
8. Age (years)

Of the 768 tested, the ratio of negative to positive test results is as follows:

Tested negative for diabetes: 500
Tested positive for diabetes:  268 

A class attribute is included in the dataset, having “class0” represent a negative diabetes test and “class1” represent a positive diabetes test; this attribute is included as the last column in the CSV data. This data set also contains some missing values, represented by a 0 in their respective columns. The 0's do not solely represent missing values, however, and some care must be taken to determine whether a 0 in any particular column represents a missing value or an actual zero-value. 

### Data Preparation

In order to prepare the data, I downloaded the 'pima-indians-diabetes.data' dataset from the UCI machine learning repository and formatted it as a CSV file. I added a header row containing abbreviated column names for the eight attributes (num_pregnant, plasma_glucose_conc, blood_pressure, tricep_sf_thickness, 2hr_insulin, bmi, diab_ped_func, age). I normalized all of the numeric column data to get values in the range [0,1] using the WEKA normalization filter. I also nominalized the 'class' attribute from a numeric value to a string value, mapping 0 to “class0” and 1 to “class1”. I saved this newly-formatted CSV file containing normalization and nominalization as 'pima.csv'.

### Attribute Selection

I employed the use of the Correlation Feature Selection (CFS) technique while preparing my data, in the hopes that such a feature selection could improve the accuracy of my classifiers. CFS evaluates subsets of features on the basis of the following hypothesis:

"Good feature subsets contain features highly correlated with the classification, yet uncorrelated to each other”

The central assumption when using a feature selection technique like this is that the data in question contains many redundant or irrelevant features. These features either provide no more information than the currently selected features do, or they do not provide any useful information in any context at all. WEKA contains an easy to use CFS feature-selector which I used to select my limited subset of attributes. It chose the following four features as the most relevant:

- Plasma glucose concentration
- Body Mass Index
- Diabetes pedigree function
- Age

Results & Discussion
------

Below I have compiled a table of accuracies comparing the performance of several well-known classifier algorithms in relation to one another, and in relation to my implementations:

WEKA - accuracy on test set [%] 

|                       | ZeroR  | 1R     | 1-NN   | 5-NN   | NB     | DT     | MLP    | SVM    |
| --------------------- | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| No feature selection  | 65.104 | 72.135 | 70.182 | 73.177 | 76.302 | 73.828 | 75.130 | 77.344 |
| CFS feature selection | 65.104 | 72.135 | 68.359 | 73.828 | 77.474 | 74.870 | 75.260 | 76.953 |

My implementation - accuracy on test set [%]*

|                       | My 1-NN | My 5-NN | My NB  |
| --------------------- | ------- | ------- | ------ |
| No feature selection  | 69.556  | 71.326  | 67.294 |
| CFS feature selection | 69.218  | 72.972  | 66.540 |
*determined based on average accuracy over 5 runs of the algorithm

Among the classifiers chosen for study in WEKA, ZeroR is clearly the worst. 1R performed significantly better, even in comparison to 1-NN. However, it is clear the rule-based algorithms do not provide the best accuracy. NN is a reasonable classifier when K is 5, with accuracy similar to DT. When K is 1 there is no benefit to its use over rule-based classifiers. Multi-Layer Perceptrons performed notably well, but they couldn't quite make it to the top spot. Naive Bayes and Support Vector Machines competed heavily for scores of accuracy, and were certainly the top 2 classifiers. I have found that their dominance fluctuates based on the use of CFS.
CFS feature selection was able to limit my dataset to a combination of only 4 attributes (plasma_glucose_conc, bmi, diab_ped_func, age). Intuitively it makes sense that these are the most correlated, especially with regards to bmi and age. There are several studies showing that obesity is the number one risk factor for diabetes, because fat interferes with the body's ability to use insulin. Also, aging leads to a slowing down of the functions in the pancreas, resulting in a reduced effectiveness for pumping insulin.
The general effects of this feature selection among the various algorithms in WEKA were varied. ZeroR, 1R, and MLP were all essentially unaffected by the change. Nearest Neighbor lost accuracy when K was 1, but increased slightly when K was 5. SVM actually lost accuracy, interestingly enough.  Both Naive Bayes and Decision Trees gained a full percent more accuracy in CFS, making Naive Bayes the algorithm with the highest overall accuracy of 77.474%. 
Among my implementations, I have noted many curious details. My 1-NN implementation is fairly similar to the WEKA's, falling behind by only about half a percent, and performing slightly better when CFS is applied. My 5-NN also couldn't quite match the accuracy of WEKA's implementation, but it came reasonably close. My 5-NN was very sensitive to the use of CFS feature selection, bringing its accuracy up by over 1.5 and giving it an accuracy of almost 73%, which is quite comparable to the standard version. I was very surprised (and admittedly disappointed) to find that My NB failed miserably in comparison to WEKA's NB classifier. Not only did its performance lag behind by almost 10 percent points, but its performance also worsened when evaluated on a CFS subset. This is peculiar, especially considering that I have found NB to be the strongest algorithm when using CFS in WEKA. Although I am fairly confident that I have a correct implementation, there may be some details I am lacking. Perhaps NB is using more sophisticated techniques of evaluation than I am, or more precise measurements of probability density. 
When considering running time for the algorithms, My K-NN takes ~22 seconds to run vs. WEKA's almost instant calculations. There is certainly room for improvement there. My NB is much faster, taking ~7 seconds (still not a great running time), but the loss in accuracy doesn't seem to make it worth the speed gain. MLP had the slowest running times among WEKA's algorithms, which were still under a second, and was followed by SVM and more distantly by DT. 
When considering the accuracy of my program by class, I noticed that both My K-NN and My NB had fairly good performance when attempting to classify “class0” instances, but significantly less precision when it came to “class1”. My NB often had accuracies for “class1” in the single digits, and often is not able to classify any “class1” instances at all. This might have something to do with the larger number of “class0” instances, contributing to a greater probability for them being chosen. Or it could be a result of an erroneous calculation for probability density. My K-NN was significantly more balanced in this respect, and has in some cases classified over 70% of “class1” instances correctly for a fold.

### Dealing with Missing Values

I spent a great deal of time during my programming attempting to compensate for the presence of missing values in the dataset. I used a method of evaluation for determining whether zero-values present in a row in the data set were missing values based on the standard deviation of values in the row. I first determine the standard deviation for the row with the zeroes, and then I remove them and determine the new standard deviation. If the difference between these values is significant (0.05 was my threshold, determined after experimenting with various data rows), I remove the zero-values and subsequently make sure to ignore those specific columns when comparing against the row we are attempting to classify. This means that missing values for an attribute cause that attribute to be omitted in considering any calculations concerning that attribute's row and the row we are comparing it to. Missing values are dangerous because they can lead to misclassifications, or can distort calculations of distance or probability density.
One issue with zero-values in the dataset, which I did not have time to account for, was that in some instances they would multiply out through the calculation and make the entire expression zero. This may be the major issue in my implementation of Naive Bayes, making any row with a zero value basically useless. If I had the time I would have modified the program to include an implementation of Laplace correction to give zero values some infinitesimal increase in value, keeping them from discounting the entire expression. 

Conclusions
-------

I have drawn several conclusions from my involvement in this experiment. First, it seems that while there are many very good algorithms for predicting these diabetes classifications, none of them seem quite good enough to be effective on their own. With the highest accuracy of ~77.5%, Naive Bayes paired with CFS feature selection is the best bet. But 77.5% percent is still fairly unreliable, especially when considering the serious nature of its judgement. While algorithms such as these could be useful corollaries to an evaluation of diabetes, they should never be given complete confidence.
In the interest of improving performance, Correlation-based Feature Selection usually improves the accuracy of a classifier, or at the very least does not affect it. Also, K-NN is quite sensitive to values of K, and should most likely always have a K-value greater than 1. I have found that cleansing missing values is an important tactic for improving the accuracy of a classifier, as it allows for the inclusion of more data points. Naive Bayes is very sensitive to zero-values in the numerator of its probability density function, and I believe an implementation of Laplace correction would have greatly benefited the accuracy that my version was lacking.
I would suggest that future work focus on improving accuracy as much as possible. In regards to my own algorithms, I believe that running time was the largest issue. That is what I would like to personally improve. But overall the nature of these classifier algorithms makes them unreliable on a regular basis, and I believe that increasing the general accuracy to be above, say, 85% would greatly benefit their usefulness. 

Reflection
-------

This assignment has gotten me deeply involved with several popular techniques of machine learning and has given me many insights into the nature of classifiers. I was happy to see that one of my algorithms was able to compete on an accuracy level with those available in WEKA. I learned about how to work with large datasets, especially those that contain missing values, zero values, or are otherwise imperfect. I was able to improve my programming skills when tackling the implementation of these algorithms, especially when dealing with the various nuances that presented themselves along the way. It is interesting to see the impact these algorithms really have, and how they can be applied in a situation as meaningful as predicting diabetes based on relevant information. I learned the importance of feature selection, and how it can improve a program's accuracy by removing unnecessary or irrelevant information. Comparing the various classifiers between my work and WEKA let me see how their performance directly compared to each other when evaluated on the same set of data. 

How To Run My Code
-------

My implementation is written using Ruby 1.9.3p374, and as such it would be best for any machine running my program to have Ruby installed and updated to this version, as some methods may not be available in older versions. To run my program, simply navigate to its location on a console, and run either of the program files available based on algorithm-type. For example, when I want to run my implementation of K-NN on my machine, I run this command in the terminal:

./k_nearest_neighbor.rb

There is also an option to provide a CSV file for evaluation, simply pass in the name of the file:

./naive_bayes.rb 'pima-CFS'

Do not include the extension, as it is assumed to be '.csv'. The default dataset is 'pima.csv'. All dataset files must be located within the 'data' sub-directory. The runnable program files I have created are 'k_nearest_neighbor.rb' and 'naive_bayes.rb', with 'utils.rb' acting as a general repository for useful common methods. When run, my program will create a file called 'pima-folds.csv' representing the current execution's folding structure. As the program performs its calculations, it prints relevant data to the console for each fold and a summary at the end showing the average accuracy across all 10 folds. My K-NN has a default K of 5, I did not have time to allow this to be changed from the console, but all that is required is a simple change to the variable k in the initialize method on line 5 to achieve other K-values.
