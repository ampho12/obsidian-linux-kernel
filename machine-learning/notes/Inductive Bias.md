
Any assumptions baked into
1. Model Architecture
2. Training Procedure
3. Objective 

That makes is prefer some solutions over another



## Architecture
Any architecture has some inductive bias.


1. Fully Connected Network: very little inductive bias, but data hungry
2. A convolutional neural network assumes
    1. spatial locality
    2. translational equivariance (not invariance): a pattern that matters one location matters at another location. Wrong for some tasks, but hugely useful for vision.
    3. 

3. A recurrent neural network assumes sequential structure.
4. A transfomer assumes set structure with pairwise interactions. Any element can interact / attend to any other element. This is similar to convolution but need more data and are more general.


### FiLM

This is a technique that adds inductive bias. A conditioning signal should act as control signal that modulates features, not as an input into the same network.

## Loss Function

- MSE biases toward predicting the mean.
- cross entropy biases toward calibrated probablities.


## Optimization

- SGD with small learning rate biases toward flat minima
- Weight Decay biases toward minimal norm solutions. (what even)


## Data Augmentation

- Random crops tell the model "translation shouldn't change the answer"
- Color Jitter "exact colors don't matter"

## Parameter Sharing

Tying weights (eg LLM input/output embedding) says these two functions should be related.



### Equivariance vs Invariance

Equivariance: if a feature moves by (dx, dy),  the activation also moves by (dx, dy).
Invariance: if feature moves by (dx, dy). The activation doesn't move much.

E.g. Maxpooling in CNNs network will introduce invariance. 

