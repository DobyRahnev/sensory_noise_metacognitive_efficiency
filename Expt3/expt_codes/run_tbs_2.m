%run_tbs_2

try

    %Set contrast based on practice session
    intermediate_contrast = input('Contrast: ');
    
    %Open window and do useful stuff
    [window,width,height] = openScreen();

    Screen('TextFont',window, 'Arial');
    Screen('TextSize',window, 20);
    Screen('FillRect', window, 127);
    wrapat = 55;

    number_blocks = 5;
    number_trials_per_block = 140;
    time = GetSecs;
    feedback = 0;

    %Take current time
    current_time = clock;
    text_results = ['results' num2str(current_time(3)) '_' num2str(current_time(4)) '_' num2str(current_time(5)) ''];

    %Initial instructions
    initial_instructions(window, width, height, intermediate_contrast);

    %Choose contrasts
    contrast = [intermediate_contrast*.75, intermediate_contrast, intermediate_contrast*1.25];

    %General instructions
    text = 'Hope that this was enough to remind you of the task. Let''s proceed to the main experiment.\n\nNow you will experience 5 blocks of trials. Each block will consist of 140 trials. You won''t be given feedback after each trial for any of the blocks but only in the end of each block. You will have 20 seconds of rest in-between blocks.\n\nPress any key to start with the experiment!';
    DrawFormattedText(window, text, 300, 'center', 255, wrapat);
    Screen('Flip',window);
    WaitSecs(1);
    KbWait;

    %Start the sequence of blocks
    for block_number=1:number_blocks

        %Instructions
        number_block_string = num2str(block_number);
        text_block = ['BLOCK (' number_block_string ' out of 5)'];
        DrawFormattedText(window, text_block, 'center', height/2, 255);
        Screen('TextSize',window, 20);
        Screen('Flip',window);
        WaitSecs(5);

        %Display the block
        data{block_number} = one_block(window, width, height, contrast, number_trials_per_block, feedback);

        %Feedback
        if block_number < number_blocks
            points_text = num2str(data{block_number}.points);
            message = ['In this block you had an oveall score of ' points_text ''];
            Screen ('DrawText', window, message, width/2-200, height/2-100, 255);
            Screen ('DrawText', window, 'You have 20 seconds before the next block starts.', width/2-200, height/2, 255);
            Screen('Flip',window);
            WaitSecs(15);
        end

        eval(['save ' text_results ' data']);
    end

    %Done with first half
    text = 'You are done with the first half of the experiment!\n\nPlease call the experimenter at 14697.';
    DrawFormattedText(window, text, 300, 'center', 255, wrapat);
    Screen('Flip',window);
    WaitSecs(15);
    KbWait;

    %Continue with second half
    text = 'The second part of the experiment will look exactly the same as the first half. You will have 5 blocks of 140 trials each.\n\nPress any key when you are ready to continue with the second part of the experiment.';
    DrawFormattedText(window, text, 300, 'center', 255, wrapat);
    Screen('Flip',window);
    WaitSecs(1);
    KbWait;
    
    %Start the sequence of blocks
    for block_number=1:number_blocks

        %Instructions
        number_block_string = num2str(block_number);
        text_block = ['BLOCK (' number_block_string ' out of 5)'];
        DrawFormattedText(window, text_block, 'center', height/2, 255);
        Screen('TextSize',window, 20);
        Screen('Flip',window);
        WaitSecs(5);

        %Display the block
        data{5 + block_number} = one_block(window, width, height, contrast, number_trials_per_block, feedback);

        %Feedback
        if block_number < number_blocks
            points_text = num2str(data{5 + block_number}.points);
            message = ['In this block you had an oveall score of ' points_text ''];
            Screen ('DrawText', window, message, width/2-200, height/2-100, 255);
            Screen ('DrawText', window, 'You have 20 seconds before the next block starts.', width/2-200, height/2, 255);
            Screen('Flip',window);
            WaitSecs(15);
        end

        eval(['save ' text_results ' data']);
    end
    
    %Finito
    text = 'You are done with the experiment!\n\nPlease call the experimenter at 14697.';
    DrawFormattedText(window, text, 300, 'center', 255, wrapat);
    Screen('Flip',window);
    WaitSecs(15);
    KbWait;
    
    %End. Close all windows
    Screen('CloseAll');

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end