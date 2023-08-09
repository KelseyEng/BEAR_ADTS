%Kelsey Snapp
%Kab Lab
%6/3/22
% Plays a sound to alert operator. Current Sound from 
% https://www.zapsplat.com/?s=chime&post_type=music&sound-effect-category-id=

function musicHelp()

    [y,Fs] = audioread('helpSound.mp3');
    sound(y,Fs);
    
end