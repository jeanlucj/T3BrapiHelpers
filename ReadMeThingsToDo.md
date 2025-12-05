ReadMe / ThingsToDo

1. Decide whether to call trials trials or studies and then be consistent. Given
that I want this to be breeder friendly, I will go with trial rather than study.

DONE.  I kept the word "study" when naming variables that interact with BrAPI.
So "study ID", or "studyDbID", or "study_id_vec".  But I use the word trial 
anytime it's in a plain English context.  At least, that's the idea.

2. getTraitsFromTrialVec: submit a vector of trials and get back what traits 
were evaluated in those trials

In Progress.  There is a function that uses the wizard feature.  I would prefer
it to use straight BrAPI calls but 1. I don't know how to do that.  Also there
should be an option to do this by trial resulting in a tibble response.

3. combingGenomicRelationshipMatrices: not sure how this will work. Will model
it on what Tim has done

4. Replace all of the examples that use the mock BrAPI connection with
connections to the wheat-sandbox.

DONE.  I think more examples could be given.  Earlier I eliminated some examples
because the mock brapi connection that ChatGPT invented didn't work.
