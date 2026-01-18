ReadMe / ThingsToDo

1. Decide whether to call trials trials or studies and then be consistent. Given
that I want this to be breeder friendly, I will go with trial rather than study.

DONE.  I kept the word "study" when naming variables that interact with BrAPI.
So "study ID", or "studyDbID", or "study_id_vec".  But I use the word trial 
anytime it's in a plain English context.  At least, that's the idea.

2. getTraitsFromTrialVec: submit a vector of trials and get back what traits 
were evaluated in those trials

DONE. The response is a two column tibble with the second column being a one
column tibble with all of the trait names or DbIds.

3. combingGenomicRelationshipMatrices: not sure how this will work. Will model
it on what Tim has done

4. Replace all of the examples that use the mock BrAPI connection with
connections to the wheat-sandbox.

DONE.  I think more examples could be given.  Earlier I eliminated some examples
because the mock brapi connection that ChatGPT invented didn't work.

5. getLatLongFromTrialVec: submit a vector of trials and get back their 
lattitude and longitude.  Or maybe just add this to the metadata when you use
a getTrialMetadata function.

