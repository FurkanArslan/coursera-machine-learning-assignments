function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

%% ================ Cost Function Without Regularization ================

% Add bias to the input layer
X = [ones(m, 1) X];

% calculate activation for hidden layer
z2 = X * Theta1';
a2 = sigmoid(z2);

% Add bias to the hidden layer
a2 = [ones(m, 1) a2];

% calculate activation for output layer
z3 = a2 * Theta2';
hx = sigmoid(z3);

% Convert real y values to 10 dimensional vector. In this vector only
% actual value is 1 other values are 0. 
y_values = zeros(m, num_labels);
for i=1:m
    y_values(i,y(i))=1;
end

h1 = -y_values .* log(hx);
h2 = (1 - y_values) .* log(1 - hx);

%calculate errors for all the labels
sumOverAllLabels = sum(h1 - h2 , 2);
%Then calculate errors for the examples in the dataset
sumOverAllExamples = sum(sumOverAllLabels);

J = (1/m) * sumOverAllExamples;

%% ================ Cost Function With Regularization ================
theta1ForRegularization = Theta1(:,2:end);
sumOverInputUnitsInTheta1 = sum(theta1ForRegularization.^2,2);
sumOverAllNodesInTheta1 = sum(sumOverInputUnitsInTheta1);
 
theta2ForRegularization = Theta2(:,2:end);
sumOverInputUnitsInTheta2 = sum(theta2ForRegularization.^2,2);
sumOverAllNodesInTheta2 = sum(sumOverInputUnitsInTheta2);

regularizationTerm = (lambda/(2*m)) * ( sumOverAllNodesInTheta1 + sumOverAllNodesInTheta2) ;

J = J + regularizationTerm;
%% ================ Backpropagation Algorithm ================
a3 = hx;

for t=1:m
    % calculate backpropagation for output layer
    error3 = zeros(num_labels, 1);
    
    for k=1:num_labels
        yk = y(t) == k;
        error3(k) = a3(t,k) - yk;
    end
    
    % adding bias unit to hidden layer
    z2t = [1, z2(t,:)];
    % calculate backpropagation for hidden layer
    error2 = (Theta2' * error3) .* sigmoidGradient(z2t)'; 
    
    Theta1_grad = Theta1_grad + error2(2:end) * X(t,:);
    Theta2_grad = Theta2_grad + error3 * a2(t,:);
    
end

Theta1_grad = (1/m) * Theta1_grad;
Theta2_grad = (1/m) * Theta2_grad;

%% ================ Regularized Neural Networks ================

%regularize theta1
temp = Theta1; 
temp(:, 1) = 0;   % because we don't add anything for j = 0  

% Formula for the gradient of the regularized cost function
Theta1_grad = Theta1_grad + ( (lambda/m) .* temp);

%regularize theta2
temp = Theta2; 
temp(:, 1) = 0;   % because we don't add anything for j = 0 

% Formula for the gradient of the regularized cost function
Theta2_grad = Theta2_grad + ( (lambda/m) .* temp);

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end
