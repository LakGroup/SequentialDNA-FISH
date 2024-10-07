# Sequential DNA-FISH analysis
This Github page includes the data files that were used to run the DNA-FISH analysis for the publication entitled '_Multiple allelic configurations govern long-range Shh enhancer-promoter communication in the embryonic forebrain_', by Harke et al.

## System requirements
The files were tested in MATLAB R2022b (The MathWorks, USA), on a i7-12700H 2.30 GHz (32 GB RAM) laptop running Windows 64-bit. The code was not tested in another version of MATLAB.

## Installation and run guide
To install:
  - Download the full folder to your computer.
  - Add the full folder to your MATLAB path 
  ```
  Option 1: Navigate to the folder through the 'Current Folder' menu and right click -> Add To Path -> Selected Folders and Subfolders
  Option 2: Home tab in MATLAB -> Environment group: Set Path -> Add with Subfolders -> Select the folder in the input dialog -> Save -> Close
  ```

A typical "installation" should not take you longer than a minute.

## Run the analysis
The main order of operations is:
- Use vutara.m (vutara folder) to determine sigma and alpha values for each set of images on a small FOV (fiducial/”reference” and walks)
- Use vutara_batch.m (vutara folder) to apply sigma and alpha calls across all data/the entire FOV
- Use vutara_link_walks.m (vutara_link_walks folder) to link fiducial and walk datasets together for visualization, distance calculations and data matrices export

Additionally:
- In vutara_link_walks.m (vutara_links_walks folder), the function “plot_traces” can be used for exporting the ball and stick 3-D images of individual data matrices
