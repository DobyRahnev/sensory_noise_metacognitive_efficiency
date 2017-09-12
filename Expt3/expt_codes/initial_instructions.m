function initial_instructions(window, width, height, intermediate_contrast)

wrapat = 55;

%Hello
text = 'Thank you for coming again for the next session of the study!\n\nPress any key to continue.';
DrawFormattedText(window, text, 300, 'center', 255, wrapat);
Screen('Flip',window);
WaitSecs(1);
KbWait;

%Example trials
text = 'Let''s start with a short practice block to remind you of the task after which we''ll immediately start with the experiment. Just to remind you: On each trial you need to indicate the tilt (right or left) of a grating. You will also need to indicate your confidence. There will be 4 possible answers:\n1: "Certainly left"\n2: "Guess left"\n3: "Guess right"\n4: "Certainly right"\n\nEach correct "certain" answer will give you 2 points, while an incorrect "certain" answer will result in subtraction of 2 points. For the "guess" answers you will be given 1 point for a correct answer but won''t have points taken off for an incorrect answer. Mathematically, you should use the "confident" answer when you have more than 66% certainty that you know the correct tilt. If you feel that you are less than 66% certain, then you should use the "guess" answer. Try to maximize your score!\n\nYou will have 2 seconds to give your answer. If you don''t answer on time, this will result in subtraction of 4 points! Try to answer quickly in order to avoid this punishment. Let''s now do a short block with feedback with the contrast that you will experience during the rest of the experiment.\n\nPress any key to begin the practice.';
DrawFormattedText(window, text, 300, 'center', 255, wrapat);
Screen('Flip',window);
WaitSecs(1);
KbWait;
contrasts = [intermediate_contrast*.75, intermediate_contrast, intermediate_contrast*1.25];
one_block(window, width, height, contrasts, 2, 1);