
# Multimodality

For the same observations, multiple valid actions might exist. If there is an object in front of the robot and it has to reach the other side, it might go around left or go around right.

The action distribution is multimodal (two peaks). Standard policy approaches like Gaussian regression collapse this to a single mean (reaching through the middle, which might be invalid).

