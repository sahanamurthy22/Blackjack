% Scene 1, welcome screen with play button
card_scene = simpleGameEngine('blacksprites.png',16,16,16,[0,100,0]); 
welcome_scene = ones(5,5);
welcome_scene(3,3) = 77;
drawScene(card_scene, welcome_scene); 
 text(0.5, 0.9, 'Welcome to Blackjack!', 'Color', 'white', 'FontSize', 25, ...
      'HorizontalAlignment', 'center', 'Units', 'normalized');

r = 0; % initiazing the variable r, which indexes the row the player clicks
c = 0; % initiazing the variable c, which indexes the column the player clicks

% until the user clicks the play button, indexed at [3,3] mouse keeps prompting for input (click from the player)
while (r ~= 3 && c ~= 3) 
    [r,c] = getMouseInput(card_scene);
end

gameOver = false;
% Initialize scorekeeping variables
userName = input('Enter your name: ', 's');
numMatches = 0;
winAndloss = []; % Records each round as win (1) or loss (0)
moneyWinLoss = 1000; % Tracks money won or lost in each round

% Helper function to map card values (J, Q, K -> 10; Ace -> 11)
map_card_values = @(val) min(val, 10);

% Function to adjust hand value for Aces
function hand_value = adjust_for_aces(hand_value, card_vals)
    % Count the number of Aces (value 1) in the hand
    num_aces = sum(card_vals == 1);
    
    % If there are Aces, we check if we can count them as 11 without busting
    if (num_aces > 0)
        for i = 1:num_aces
            if hand_value <= 11  % If the total is 11 or less, we can safely add 10 for an Ace
            hand_value = hand_value + 10;  % Count Ace as 11 instead of 1
            end
        end
    end
end

% Function to create a dynamically sized scene matrix
    createSceneMatrix = @(num_player_cards) ...
    ones(5, max(num_player_cards, 5)); % Ensure at least 5 columns for spacing

 while (~gameOver)
    availableFunds = sum(moneyWinLoss);

    % Scene 2, making a bet
    betting_scene = 2 * ones(3, 3);
    drawScene(card_scene, betting_scene);

    % Dialog box
    prompt = {sprintf('You have $%.2f, enter your amount, or else (don''t try and be funny):', availableFunds)};
    dialog = 'Place your Bet';
    dims = [1 40];
    default_input = {'0'}; 
    bet_amount = inputdlg(prompt, dialog, dims, default_input); % If this doesn't work as get...Input function for grading, just talk to me. Totally understand if it doesn't work.

    % Convert bet amount from cell array to a numeric value
    bet_amount = str2double(bet_amount{1});

    while (bet_amount > availableFunds)
        msgbox('You don''t have enough funds. Enter a valid amount.', 'Insufficient Funds', 'warn');
        pause(1.5);
        prompt = {sprintf('You have $%.2f, enter your amount, or else (don''t try and be funny):', availableFunds)};
        dialog = 'Place your Bet';
        dims = [1 40];
        default_input = {'0'}; 
        bet_amount = inputdlg(prompt, dialog, dims, default_input); 
        bet_amount = str2double(bet_amount{1});
    end

    % Preparing the card logic
    skip_sprites = 20; % Convenience for the sprite indexing
    pcard_vals = randi(13, 1, 15); % player card values
    pcard_suits = randi(4, 1, 15) - 1; % player card suits
    hcard_vals = randi(13, 1, 15); % house card values
    hcard_suits = randi(4, 1, 15) - 1; % house card suits
    pcard_value = sum(map_card_values(pcard_vals(1:2))); 
    pcard_value = adjust_for_aces(pcard_value, pcard_vals(1:2));
    hcard_value = sum(map_card_values(hcard_vals(1:2))); 
    hcard_value = adjust_for_aces(hcard_value, hcard_vals(1:2));
    i = 2;

    % Reset input variables
    r = 0;
    c = 0;

    % Scene 3, blackjack initial phase
    pause(0.5);
    pcard_sprites = skip_sprites + 13*(pcard_suits) + pcard_vals; % Convenience with the card array indexing
    hcard_sprites = skip_sprites + 13*(hcard_suits) + hcard_vals; % Convenience with the card array indexing
    % sprites_to_display = [3, hcard_sprites(2); 1, 1; 75, 76; 1, 1; pcard_sprites(1:2)];
    % drawScene(card_scene, sprites_to_display);

    % Display initial cards
    scene_matrix = createSceneMatrix(2);
    scene_matrix(1, 1:2) = [3, hcard_sprites(2)];    % Dealer's cards
    scene_matrix(3, 1:2) = [75, 76];              % Hit/Stand buttons
    scene_matrix(5, 1:2) = pcard_sprites(1:2);    % Player's cards

    % Draw the initial scene
    drawScene(card_scene, scene_matrix);
    text(0.2, 0.25, 'Player''s Hand', 'Color', 'white', 'FontSize', 25, ...
      'HorizontalAlignment', 'center', 'Units', 'normalized');
    text(0.2, 0.75, 'Dealer''s Hand', 'Color', 'white', 'FontSize', 25, ...
      'HorizontalAlignment', 'center', 'Units', 'normalized');

    % Main loop
    while (pcard_value <= 21)
        % Wait for player input (Hit button)
        while (r ~= 3 && c ~= 2)
            [r, c] = getMouseInput(card_scene);
        end

        % Player chose to "Hit"
        if (r == 3 && c == 1)
            i = i + 1;
            pcard_value = sum(map_card_values(pcard_vals(1:i)));
            pcard_value = adjust_for_aces(pcard_value, pcard_vals(1:i));

            % Update the scene matrix with the new card
            scene_matrix = createSceneMatrix(i);
            scene_matrix(1, 1:2) = [3, hcard_sprites(2)]; % Dealer's cards
            scene_matrix(3, 1:2) = [75, 76];              % Hit/Stand buttons
            scene_matrix(5, 1:i) = pcard_sprites(1:i);    % Player's cards

            % Redraw the scene
            drawScene(card_scene, scene_matrix);

        % Player chose to "Stand"
        elseif (r == 3 && c == 2)
            break; % exits the while loop
        end

        % Reset input variables
        r = 0;
        c = 0;
    end

    % Display dealer's "hole" card
    scene_matrix = createSceneMatrix(i);
    scene_matrix(1, 1:2) = [hcard_sprites(1), hcard_sprites(2)]; 
    scene_matrix(3, 1:2) = [75, 76];            
    scene_matrix(5, 1:i) = pcard_sprites(1:i); 
    % Redraw the scene
    drawScene(card_scene, scene_matrix);

    if (pcard_value <= 21)
        % house plays
        % if house busts, player wins
        % if house stands, house either ties, wins, or loses to player
        j = 2;
        while (hcard_value < 17)  % Dealer hits until their value is at least 17
            % Simulate dealer hit (no mouse input needed)
            j = j + 1;
            hcard_value = sum(map_card_values(hcard_vals(1:j)));  % Update dealer's hand value
            hcard_value = adjust_for_aces(hcard_value, hcard_vals(1:j));
        
            % Update the scene matrix with the new card
            scene_matrix = createSceneMatrix(i);
            scene_matrix(1, 1:j) = hcard_sprites(1:j);  % Dealer's updated cards
            scene_matrix(3, 1:2) = [75, 76];  % Hit/Stand buttons (for reference)
            scene_matrix(5, 1:i) = pcard_sprites(1:i);  % Player's cards
            drawScene(card_scene, scene_matrix);  % Redraw the scene
        
            pause(1);  % Pause briefly to show the dealer's action (optional for game pacing)
        end
    end

    if ((pcard_value > 21) || (hcard_value <= 21 && hcard_value > pcard_value))
        winAndloss(end + 1) = 0;  % Player loses
        moneyWinLoss(end + 1) = -bet_amount;
        disp('You lost this round.');
    elseif((pcard_value <= 21 && hcard_value > 21) || ((pcard_value <= 21 && hcard_value <=21) && (pcard_value > hcard_value)))
        winAndloss(end + 1) = 1;  % Player wins
        moneyWinLoss(end + 1) = bet_amount;
        disp('You won this round!');
    elseif ((pcard_value <= 21 && hcard_value <= 21) && (pcard_value == hcard_value))
        moneyWinLoss(end + 1) = -bet_amount;
        winAndloss(end+1) = 0; % Tie counts as a loss on the player's end
        disp('You tied this round!');
    end
    numMatches = numMatches + 1; % Increment the number of matches% Initialize counters for total wins, losses, and money

    totalWins = sum(winAndloss == 1);
    totalLosses = sum(winAndloss == 0);
    totalMoney = sum(moneyWinLoss);

    % Display the final results
    textStr = sprintf('Username: %s\n\nGame Summary:\nTotal Matches Played: %d\nTotal Wins: %d\nTotal Losses: %d\nAvailable Funds: $%.2f\n', ...
                  userName, numMatches, totalWins, totalLosses, totalMoney);

    % Create a figure and display text in a text box
    figure;
    uicontrol('Style', 'text', 'Position', [100, 100, 300, 150], 'String', textStr, 'HorizontalAlignment', 'left');

    pause(6);
    close;
    
    availableFunds = sum(moneyWinLoss);

    if (availableFunds <= 0) 
        disp('Game over, you have no funds left to bet.')
        gameOver = true;
        close all
    end
end







