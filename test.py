import numpy as np
from scipy.spatial.distance import pdist, squareform

# 1. Define the coordinates of the points (A through M, excluding K)
# Points: A, B, C, D, E, F, G, H, I, J, L, M
data_points = np.array([
    [0.0, 0.0],  # A
    [1.0, 1.0],  # B
    [1.0, 2.0],  # C
    [1.0, 3.0],  # D
    [2.0, 2.0],  # E
    [2.0, 1.0],  # F
    [3.0, 1.0],  # G
    [4.0, 4.0],  # H
    [5.0, 5.0],  # I
    [5.0, 6.0],  # J
    [6.0, 6.0],  # L
    [6.0, 5.0]   # M
])

point_labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'L', 'M']

# Define the DBSCAN parameters
MinPts = 3
EPS = 1
print(f"DBSCAN Parameters: MinPts = {MinPts}, EPS (Epsilon) = {EPS}\n")

# ---
# 2. Compute the Proximity Matrix (Euclidean Distance Matrix)
# pdist computes the pairwise distances between all points
# squareform converts the condensed distance vector to a square matrix

# Calculate the condensed distance vector
condensed_distance_vector = pdist(data_points, metric='euclidean')

# Convert to a square (12x12) proximity matrix
proximity_matrix = squareform(condensed_distance_vector)

print("## Proximity Matrix (Euclidean Distance) ##")
# Print the matrix with labels and 2 decimal places for readability
print("       " + "   ".join([f"{label:^5}" for label in point_labels]))
for i in range(len(point_labels)):
    row_str = " ".join([f"{d:5.2f}" for d in proximity_matrix[i]])
    print(f"{point_labels[i]:>5}  {row_str}")

print("\n" + "-"*75 + "\n")

# ---
# 3. Apply the DBSCAN Logic (Optional, but helpful for the rest of the exercise)

# Step 3a: Create the Reachability Matrix (1 if distance <= EPS, 0 otherwise)
# This matrix shows which points are in the neighborhood of others.
reachability_matrix = (proximity_matrix <= EPS).astype(int)

# Set the diagonal to 0 as a point is not considered its own neighbor for MinPts count
np.fill_diagonal(reachability_matrix, 0) 

print("## Reachability Matrix (1 if distance <= EPS=1) ##")
print("       " + "   ".join([f"{label:^5}" for label in point_labels]))
for i in range(len(point_labels)):
    row_str = " ".join([f"{r:5d}" for r in reachability_matrix[i]])
    print(f"{point_labels[i]:>5}  {row_str}")

print("\n" + "-"*75 + "\n")

# Step 3b: Determine the type of each point (Core, Border, or Noise)
# A point is a CORE point if it has at least MinPts (3) neighbors within EPS (1).

neighbor_counts = reachability_matrix.sum(axis=1)

print("## Point Type Determination (MinPts=3) ##")
print(f"| Point | Neighbors (Count) | Type |")
print("|:-----:|:-----------------:|:----:|")
for i, count in enumerate(neighbor_counts):
    point_type = ""
    if count >= MinPts:
        point_type = "Core"
    # Border/Noise requires full DBSCAN logic, but we can identify Core points here
    else:
        point_type = "Potential Border/Noise"
    print(f"| {point_labels[i]:^5} | {count:^17} | {point_type:^4} |")