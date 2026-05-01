

A model optimization converges when weights don't move much. This can be due to a few confounding factors

1. Error is small -> model has closed as much error as it can (data vs model?)
2. Learning rate is small -> The LR schedule is causing model to converge much quicker artificially.


At the same time, loss can be jumpy. It may increase for some epochs, then decrease, then back up. More non linearity in the network usually means more "hilly " the loss landscape, and larger gradients. Thus we need smaller learning rate to ensure we converge.

Conditioning - if loss decreases very fast along 1 direction but slowly across the other then model is hard to converge because

NLL loss for variance and mean: why it didn't work wel
1. variance head adapts quickly and absorbs loss, the slow, fast convergence dynamics don't work well here.
2. the loss jacobian is not well condiitoned.