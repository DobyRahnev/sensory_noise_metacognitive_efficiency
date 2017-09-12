function presentation = one_block(window, width, height, contrasts, number_trials, feedback)

wrapat = 55;

one = KbName('1!');
two = KbName('2@');
three = KbName('3#');
four = KbName('4$');
nine = KbName('9(');

hit = 0;
miss = 0;
cr = 0;
fa = 0;

points = 0;
number_correct = 0;
time = GetSecs + .5;

for i=1:number_trials

    %Clear the screen and show the fixation square that should stay on
    %until the stimulus comes
    Screen('TextSize',window, 40);
    Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
    Screen('TextSize',window, 20);
    Screen('Flip', window);

    %Prepare and flash the stimulus
    if rand < .5
        right_tilt = 1;
        rotation_angle = 10; %right tilt
    else
        right_tilt = 0;
        rotation_angle = 170; %right tilt
    end

    %Choose the contrast randomly
    which_contrast = ceil(3*rand);

    stimulus_matrix = makeStimulus(window, contrasts(which_contrast));
    ready_stimulus = Screen('MakeTexture', window, stimulus_matrix);

    for number_frames=1:3
        Screen('DrawTexture', window, ready_stimulus, [], [], rotation_angle);
        Screen('TextSize',window, 40);
        Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
        Screen('TextSize',window, 20);
        if number_frames == 1
            Screen('Flip', window, time);
        else
            Screen('Flip', window);
        end
    end
    Screen('TextSize',window, 40);
    Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
    Screen('TextSize',window, 20);
    Screen('Flip', window);

    %Detection question
    [hor, vert] = DrawFormattedText(window, 'What was the tilt of the grating?\n\n', width/2-100, height/2+100, 255);
    [hor, vert] = DrawFormattedText(window, '1: Certainly left\n', width/2-100, vert, 255);
    [hor, vert] = DrawFormattedText(window, '2: Guess left\n', width/2-100, vert, 255);
    [hor, vert] = DrawFormattedText(window, '3: Guess right\n', width/2-100, vert, 255);
    [hor, vert] = DrawFormattedText(window, '4: Certainly right\n', width/2-100, vert, 255);
    Screen('TextSize',window, 40);
    Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
    Screen('TextSize',window, 20);
    Screen('Flip',window, time + .25);

    answer = -10; %in case no answer is given within the time limit
    secs = time;
    while GetSecs < time + 1.8
        [keyIsDown,secs,keyCode]=KbCheck;
        if keyIsDown
            if keyCode(one)
                answer = 1;
                break;
            elseif keyCode(two)
                answer = 2;
                break;
            elseif keyCode(three)
                answer = 3;
                break;
            elseif keyCode(four)
                answer = 4;
                break;
            elseif keyCode(nine)
                answer = bbb; %forcefully break out
            end
        end
    end
    reaction_time = secs - time;

    %Remove the question
    Screen('TextSize',window, 40);
    Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
    Screen('TextSize',window, 20);
    Screen('Flip', window);

    %Decide whether answer was correct
    correct = 0;
    if right_tilt == 1
        if answer > 2
            hit = hit + 1;
            correct = 1;
        elseif answer > 0
            miss = miss + 1;
        end
    else %right_tilt == 1
        if answer > 2
            fa = fa + 1;
        elseif answer > 0
            cr = cr + 1;
            correct = 1;
        end
    end

    %Find confidence
    if answer == 1 || answer == 4
        confidence = 2;
    elseif answer == 2 || answer == 3
        confidence = 1;
    else
        confidence = -10;
    end

    %Compute the score for each trial
    if correct == 1 && confidence == 2
        score = 2;
        color = [0 255 0];
    elseif correct == 1 && confidence == 1
        score = 1;
        color = [0 100 0];
    elseif correct == 0 && confidence == 2
        score = -2;
        color = [100 0 0];
    elseif correct == 0 && confidence == 1
        score = 0;
        color = [0 0 0];
    else
        score = -4;
        color = [255 0 0];
    end

    %Give feedback
    if feedback == 1
        text = ['Score on this trial: ' num2str(score) ''];
        DrawFormattedText(window, text, 'center', 250, color, wrapat);
        Screen('TextSize',window, 40);
        Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
        Screen('TextSize',window, 20);
        Screen('Flip',window);

        %remove feedback after 2.5 seconds
        Screen('TextSize',window, 40);
        Screen('DrawText', window, '.', width/2-5, height/2-35, 255);
        Screen('TextSize',window, 20);
        Screen('Flip', window, time + 2.2);
    end

    %Update the number of incorrect responses and time
    number_correct = number_correct + correct;
    points = points + score;

    %Update time
    if feedback == 1
        time = time + 2.5;
    else
        time = time + 2;
    end

    %Save data
    presentation.answer(i) = answer;
    presentation.rt(i) = reaction_time;
    presentation.answered_correct(i) = correct;
    presentation.right_tilt(i) = right_tilt;
    presentation.which_contrast(i) = which_contrast;
end

presentation.number_correct = number_correct;
presentation.points = points;
presentation.contrasts = contrasts;

%Compute d'
if hit == 0
    hit = .5;
end
if fa == 0
    fa = .5;
end
if cr == 0
    cr = .5;
end
if miss == 0
    miss = .5;
end

percent_hit = hit/(hit+miss);
percent_fa = fa/(fa+cr);
presentation.d_prime = norminv(percent_hit) - norminv(percent_fa);

Screen('Close');