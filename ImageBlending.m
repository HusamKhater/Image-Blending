function result = ImageBlending(src, trg)

% the two images
% src = im2double(imread('bear.jpg'));
% trg = im2double(imread('pool.jpg'));

% calculating the dimintions of the target images, inorder to check if the
% choosed to put the mask out side the target limits, if he did, we will
% replace the new position of the mask to be inseide the limits of the
% target, according to the mask size and target image limits
[trgRows, trgCols, ~] = size(trg);

% showing the user the source image that we'll take the mask from it
figure, imshow(src);

% showing the user a message box that have an instructions about choosing
% the and when to finish this step
uiwait(msgbox({'please draw a mask' 'double click to finish :)'}));

% allowing the user to choose interactive mask, the user can choose the
% specific mask to put in the target image, the gca parameter is passed
% inorder to check if the user exceeded the source image limits,
% choosing the mask ends when the user double click in the mask
imHandler = imfreehand(gca);
wait(imHandler);

% after selecting the mask from the source image, we are interested to know
% the boolean view of the mask ( if the pixel is selected to be part of the
% mask or not, the value 1 indecate that this pixel is in the mask, 0 if
% this pixel is outside the mask), create mask is a build function in
% MATLAB so we used it according to the insttruction in the MATLAB help web
% page
mask = imHandler.createMask();
% figure, imshow(mask);

% after selecting the mask, we close the source image that we shown while
% choosing the mask, and move to the next step
close;

% we are interested in the most tight part of the image that is under the
% mask that we choose, so from the mask that returned from the createmask
% function, want only want to take the tight rectangle around the mask, so
% we know the left-top pixel of the mask, and the right-bottom pixel of the
% mask, and then crop this part only
[maskRow, maskCol] = find(mask);
maskMinRow = min(maskRow);
maskMaxRow = max(maskRow);
maskMinCol = min(maskCol);
maskMaxCol = max(maskCol);

% cropping the tight mask according to the user choosing
theCroppedMask = mask(maskMinRow:maskMaxRow, maskMinCol:maskMaxCol);
% imshow(theCroppedMask, []);

% we also want the suitable part of the source image that is existing under
% the mask, so now we have the relative part of the source image
theCroppedSource = src(maskMinRow:maskMaxRow, maskMinCol:maskMaxCol, :);
[m,n,~] = size(theCroppedSource);
% imshow(theCroppedSource, []);
% figure, imshow(theCroppedSource);

% now we are moveing to the next part, we are showing the user that target
% image, inorder to choose where to put the cropped mask, we also show the
% user a message box that include instructions about this part
imshow(trg);
uiwait(msgbox({'Please choose the center of the cropped image' 'Be careful not to cross the limits !' 'Note!! if you left-click, you will see the pasted sorce mask in the target without blending, this may help you to choose the rigth place you want to put the cropped source, inorder to start blending the cropped source in the target selected posetion with efficiente way you have to right-click in the wanted position'}));

% now we are allowing the user to choose a point in the target image that
% will be the center of the pasted image, we can detect the left mouse
% click and the right-click, if the use left-clicked in the image, we put
% the cropped source image in the choosen position inorder to check if the
% user choosed the right position, if the user right-click in position,
% that means that the user is sure from the new cropped source image
% position, so if the user right-clicked, we can start the blending
% algorithm that w'll be explained down
b = 1;
while b==1
    
    %with the given matlab function, we can check wether the user
    %left-clicked or right-clicked
    [y,x,b] = ginput(1);
    
    if b ~= 1
        break
    end
    
    % we do not believe the selection of the user point, so we check if the
    % selected point is outside the target image limits, if it's we change the
    % selected point to be a legal point according to the target image and to
    % the selected source image

    y = max(y,(maskMaxCol - maskMinCol)/2 + 1);
    y = min(y, trgCols-(maskMaxCol - maskMinCol)/2);
    x = max(x,(maskMaxRow - maskMinRow)/2 + 1);
    x = min(x, trgRows-((maskMaxRow - maskMinRow)/2));

    % here we are calculating the borders of the new pastd image
    fromR = (x - (maskMaxRow - maskMinRow)/2);
    toR = (x + (maskMaxRow - maskMinRow)/2);
    % R = toR - fromR + 1;

    fromC = (y - (maskMaxCol - maskMinCol)/2);
    toC = (y + (maskMaxCol - maskMinCol)/2);
    % C = toC - fromC + 1;
    
    tempCroppedTarget = trg( fromR : toR, fromC : toC , : );
    
    % we paste the cropped source in the selected target position, just to
    % be sure of the selected place
    tempTarget = trg;
    
    tempCroppedSource = tempCroppedTarget;
    for i=1:m
        for j=1:n
            if theCroppedMask(i,j)
                tempCroppedSource(i,j,:) = theCroppedSource(i,j,:);
            end
        end
    end
    tempTarget( fromR : toR, fromC : toC , : ) = tempCroppedSource;
    imshow(tempTarget);
    
    
end

% we do not believe the selection of the user point, so we check if the
% selected point is outside the target image limits, if it's we change the
% selected point to be a legal point according to the target image and to
% the selected source image
y = max(y,(maskMaxCol - maskMinCol)/2 + 1);
y = min(y, trgCols-(maskMaxCol - maskMinCol)/2);
x = max(x,(maskMaxRow - maskMinRow)/2 + 1);
x = min(x, trgRows-((maskMaxRow - maskMinRow)/2));

% here we are calculating the borders of the new pastd image
fromR = (x - (maskMaxRow - maskMinRow)/2);
toR = (x + (maskMaxRow - maskMinRow)/2);
% R = toR - fromR + 1;

fromC = (y - (maskMaxCol - maskMinCol)/2);
toC = (y + (maskMaxCol - maskMinCol)/2);
% C = toC - fromC + 1;

% the same we did in the mask selection, we are interested in the tight target
% image rectangle, so we crop the exact part of the target that maybe will
% have some changes in the colors
theCroppedTarget = trg( fromR : toR, fromC : toC , : );
% imshow(theCroppedTarget);

% inorder to be consider the border pixels of the mask, we'll add a one
% pixel arround the three cropped images (mask, source and target), so now
% we are considering the border pixels and calculate the new pixel value
% with no mistakes
paddedMask = padarray(theCroppedMask,[1,1]);
paddedSource = padarray(theCroppedSource,[1,1],'replicate');
paddedTarget = padarray(theCroppedTarget,[1,1],'replicate');

[rows, cols] = size(paddedMask);

% we'll calculate the real new value of each pixel in the new image
% according to the formula in the given article, for each pixel we'll save
% in which pixels he is related (connected neighbors), so we'll use a
% sparse matrix, a matrix that saves the coordenates of the relted
% neighbors, its a mostly zero matrix except for some valued entries, for
% each row in this matrix we present a pixel in the mask, each col in this
% matrix present the other pixel in the image,
% if matrix(i,j) = 0, that means that the pixel i in the image dosnt
% realten to the pixel j, else, (matrix(i,j) != 0) in the coefficients of
% the formula that represent the pixel i, the pixel j realted to it as the
% value that saved in matrix(i,j)
% all this definition is shown if the matlab web page
A = sparse(rows*cols, rows*cols);

% this vector will save the result of the new pixel value, this is the
% vector that will help us to know the new value for each new pixel 
B = zeros(rows*cols, 3);


% according to the artical, A*x=B, where A is the coefficients matrix, B is
% the new values of the pixels, so we can see that x is our solution, x
% saves the new value of each pixel according to A and B that we fill 


% now we are fill the A matrix and B vector according to the artical 
for j=1:cols
   for i=1:rows
      
       % if the pixel isn't under tha mask, we'll replace it with the target
       % image pixel value

       if(paddedMask(i,j) == 0)
            
           A((j-1)*rows + i, (j-1)*rows + i) = 1;
           B((j-1)*rows + i, :) = paddedTarget(i, j, :);
           
       % else, we fill the A matrix to save that this pixel is related to the connected neighbors, so in the coefficients
       % matrix we but -1 in each sutabil entry, and in B vector we save the correct new value 
       else
           
           B((j-1)*rows + i, :) = 4*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j-1, :) -paddedSource(i, j+1, :);
           A((j-1)*rows + i, (j-1)*rows + i) = 4;
           A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
           A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
           A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
           A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
           
       end



       
%        
%        if(paddedMask(i,j) == 0)
%             
%            A((j-1)*rows + i, (j-1)*rows + i) = 1;
%            B((j-1)*rows + i, :) = paddedTarget(i, j, :);
%            
%        else
%              if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 1)
%              
%                 B((j-1)*rows + i, :) = 4*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j-1, :) -paddedSource(i, j+1, :);
%                 A((j-1)*rows + i, (j-1)*rows + i) = 4;
%                 A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
%                 A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
%                 A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
%                 A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
%                 
%              else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 0)
%                      
%                     B((j-1)*rows + i, :) = 3*paddedSource(i, j, :) - paddedSource(i-1, j, :) - paddedSource(i+1, j, :) - paddedSource(i, j-1, :);
%                     A((j-1)*rows + i, (j-1)*rows + i) = 3;
%                     A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
%                     A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
%                     A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
%                
%                  else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 1)
%                          
%                          B((j-1)*rows + i, :) = 3*paddedSource(i, j, :) - paddedSource(i-1, j, :) - paddedSource(i+1, j, :) - paddedSource(i, j+1, :);
%                          A((j-1)*rows + i, (j-1)*rows + i) = 3;
%                          A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
%                          A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
%                          A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
%                 
%                       else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 1)
%                               
%                               B((j-1)*rows + i, :) = 3*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i, j-1, :) -paddedSource(i, j+1, :);
%                               A((j-1)*rows + i, (j-1)*rows + i) = 3;
%                               A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
%                               A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
%                               A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% 
%                            else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 1)
%                                    
%                                    B((j-1)*rows + i, :) = 3*paddedSource(i, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j-1, :) -paddedSource(i, j+1, :);
%                                    A((j-1)*rows + i, (j-1)*rows + i) = 3;
%                                    A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
%                                    A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
%                                    A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% 
%                                else 
%                                     
%                                    B((j-1)*rows + i, :) = 4*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j-1, :) -paddedSource(i, j+1, :);
%                                    A((j-1)*rows + i, (j-1)*rows + i) = 4;
%                                    A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
%                                    A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
%                                    A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
%                                    A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% 
% 
% %                                     if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 1)
% %                                      
% %                                         B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) - paddedSource(i, j-1, :) - paddedSource(i, j+1, :);
% %                                         A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                         A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
% %                                         A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% % 
% %                                      else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 1)
% %                                              
% %                                             B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j+1, :);
% %                                             A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                             A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
% %                                             A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% % 
% %                                           else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 0)
% %                                                   
% %                                                 B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) -paddedSource(i+1, j, :) -paddedSource(i, j-1, :);
% %                                                 A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                                 A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
% %                                                 A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
% % 
% %                                                else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 1)
% %                                                        
% %                                                         B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) -paddedSource(i-1, j, :)  -paddedSource(i, j+1, :);
% %                                                         A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                                         A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
% %                                                         A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% % 
% %                                                     else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 0)
% %                                                             
% %                                                             B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i, j-1, :);
% %                                                             A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                                             A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
% %                                                             A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
% % 
% %                                                          else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 0)
% %                                                                  
% %                                                                 B((j-1)*rows + i, :) = 2*paddedSource(i, j, :) -paddedSource(i-1, j, :) -paddedSource(i+1, j, :);
% %                                                                 A((j-1)*rows + i, (j-1)*rows + i) = 2;
% %                                                                 A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
% %                                                                 A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
% %                                                                  
% %                                                               else if(paddedMask(i-1,j) == 1 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 0)
% %                                                                       
% %                                                                       B((j-1)*rows + i, :) = 1*paddedSource(i, j, :) -paddedSource(i-1, j, :);
% %                                                                       A((j-1)*rows + i, (j-1)*rows + i) = 1;
% %                                                                       A((j-1)*rows + i, (j-1)*rows + i - 1) = -1;
% %                                                                       
% %                                                                    else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 1 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 0)
% %                                                                            
% %                                                                            B((j-1)*rows + i, :) = 1*paddedSource(i, j, :) -paddedSource(i+1, j, :);
% %                                                                            A((j-1)*rows + i, (j-1)*rows + i) = 1;
% %                                                                            A((j-1)*rows + i, (j-1)*rows + i + 1) = -1;
% % 
% %                                                                         else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 1 && paddedMask(i,j+1) == 0)
% %                                                                                      
% %                                                                                     B((j-1)*rows + i, :) = 1*paddedSource(i, j, :) -paddedSource(i, j-1, :);
% %                                                                                     A((j-1)*rows + i, (j-1)*rows + i) = 1;
% %                                                                                     A((j-1)*rows + i, (j-1)*rows + i - rows) = -1;
% % 
% %                                                                              else if(paddedMask(i-1,j) == 0 && paddedMask(i+1,j) == 0 && paddedMask(i,j-1) == 0 && paddedMask(i,j+1) == 1)
% %                                                                                           
% %                                                                                           B((j-1)*rows + i, :) = 1*paddedSource(i, j, :) - paddedSource(i, j+1, :);
% %                                                                                           A((j-1)*rows + i, (j-1)*rows + i) = 1;
% %                                                                                           A((j-1)*rows + i, (j-1)*rows + i + rows) = -1;
% % 
% %                                                                                   end
% %                                                                              end
% %                                                                         end
% %                                                                   end
% %                                                               end
% %                                                          end
% %                                                     end
% %                                                end
% %                                           end
% %                                      end
%                                 end
%                            end
%                       end
%                   end     
%              end
%        end
       
       
       
       
       
   end
end
 

% after we calculate the A and B, we now know that x is our solution, so we
% excract x from A and B
x = A\B;

% we reshape the x solution, to be a matrix with true dimintions
x = reshape(x, [rows, cols, 3]);

% after changing the dimintions, we are cropping the wanted mask from our
% solution, ( we padded it in the begeing )
theCroppedResult = x(2:rows-1, 2:cols-1, :);

% now after having the solution, we paste the new values image in the
% target image with the choosen coordnations
trg( fromR : toR, fromC : toC , : ) = theCroppedResult ;

result = trg;
end