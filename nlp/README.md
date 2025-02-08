# NLP (Natural Language Processing)
This repository contains assignments of **natural language processing** university course [2022/2023]

### Team:
- [Renato Esposito](https://github.com/RenatoEsposito1999)
- [Vincenzo Mele](https://github.com/VincenzoMele)
- Luca Rubino (me)
<br></br>
## First Assignment: Statistics and Some Preprocessing Steps
The first step was to calculate some statistics of the input corpus.
in NLP it is essential to clean up the data (therefore the text) from useless information (which varies according to the application). For this reason, the preprocessing steps were carried out, such as: <i>Tokenization, Lemmatization and Stemming.</i>
<br></br>
## Second Assignment: Sentiment Analysis
A very important task of NLP is sentiment analysis: it is a task whose objective is to verify whether the given input text is  **positive** or  **negative**. To do this we used two models provided by the  `NLTK library`: **Naive Bayes** and **Logistic Regression**. These models received input data preprocessed differently depending on the model. after which tests and evaluations ( with <i>Confusion Matrix</i> ) were made to verify the accuracy of the predictions.

### Example with LR (Logistic Regression)
Suppose that your input text is `The other day I had a pizza in Puglia, but it looked like a cookie. Really horrible and inedible`.
Output is the following:
```
Result: ['neg']
 with prob: [[0.89728656 0.10271344]]
 ```
Output is negative because <i>0.89728656</i> is the negative probability while <i>0.10271344</i> is the positive probability.
<br></br>
 

## Third Assignment: N-gram Language Model
In this assignment we want to create a word suggester (like google search does when you're typing words into the search bar). To do this, an <b>N-gram Language Model</b> is created, i.e. a <i>probability matrix</i> that is used to make predictions. Also in this case the model is tested and evaluated with the <i>perplexity measure</i>.

### Example
Suppose that your input text is `i have just`. The model output for this input is the following:
```
i have just been  -> Probability = 0.008729388942773999
i have just such  -> Probability = 0.002263174911089555
i have just taken  -> Probability = 0.002263174911089555
i have just now  -> Probability = 0.002263174911089555
i have just freed  -> Probability = 0.002263174911089555
i have just felt  -> Probability = 0.002263174911089555
i have just ask  -> Probability = 0.002263174911089555
i have just prevailed  -> Probability = 0.002263174911089555
i have just come  -> Probability = 0.002263174911089555
i have just balances  -> Probability = 0.002263174911089555
```
in this case the next word will be "been", as it has a higher probability than the others.
