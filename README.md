# R36S-Background-Music-Player

Background Music Player for the R36S [ArkOS & dArkOS]


#-Installation-#

1) Download and copy the "Background_Music_Player.sh" file to the Tools folder on the Easyroms Partition of your SD Card
2) Create a folder called "music" on the Easyroms Partition of your SD Card and fill it with all of your audio files (Mp3, Flac, Ogg)
3) Over on your R36S, navigate to the Options Menu, and run the Background Music Player from the Tools Menu


#-Usage-#

Once opened, you will have 3 menu options - Play Music, Stop Music & Exit.

"Play Music" will bring you to all of your audio files inside the music folder created earlier, and let you pick which song to start with. The next screen will ask if you want Linear or Random Playback - Random will shuffle the tracks and the next track will be random. Linear will instead play the tracks in order.

Once your Audio is playing, you can go down to Exit or Cancel to quit back to Emulation Station.

To stop the playback, simply run the script again and select "Stop Music" from the main menu.


#-Notes-#

While your custom audio is playing, there will be no audio in any games or emulators as this takes priority. Stopping the audio playback using the script, or simply resetting the device will allow games and emulators to play audio once more.


#-Overhead-#

Although decoding and playing audio in the background does slightly tax the CPU, in my tests it seems to improve performance very slightly since the emulator itself doesnt need to handle sound.


dArkOS Mega Man 2 (NES) Bubble Man Spawn Point:
	Standard FF Speed - 189
	Music Playback FF Speed - 198

dArkOS Pokemon Fire Red (GBA) Title Screen:
	Standard FF Speed - 84
	Music Playback FF Speed - 86
