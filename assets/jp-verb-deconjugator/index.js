/*
 * This module uses the grammar rules listed in derivations.js
 * and recursively applies them to the input string until the
 * verb root is reached. There will most likely be more than
 * one apparently viable deconjugation, so effort is made to
 * sort them according to liklihood.
 *
 * Full project source: https://github.com/mistval/jp-verb-conjugator
 */

const derivationTable = require('./derivations.js');
const WordType = require('./word_type.js');
const DerivationAttribute = require('./derivation_attribute.js');
const frequencyForWord = require('./frequencyForWord.json');

/*
 * For performance, map each rule to the conjugated word type that it can follow.
 */
const derivationRulesForConjugatedWordType = {};

for (let rule of derivationTable) {
  const conjugatedWordType = rule.conjugatedWordType;
  if (!derivationRulesForConjugatedWordType[conjugatedWordType]) {
    derivationRulesForConjugatedWordType[conjugatedWordType] = [];
  }
  derivationRulesForConjugatedWordType[conjugatedWordType].push(rule);
}

function getFrequencyForSuruVerb(word) {
  if (word.endsWith('する')) {
    const suruBase = word.substring(0, word.length - 2);
    return frequencyForWord[suruBase];
  }
  return undefined;
}

function isNumber(numberCandidate) {
  return typeof numberCandidate === typeof 1;
}

function compareFrequency(frequencyA, frequencyB) {
  const frequencyAIsNumber = isNumber(frequencyA);
  const frequencyBIsNumber = isNumber(frequencyB);

  if (frequencyAIsNumber && frequencyBIsNumber) {
    return frequencyA - frequencyB;
  } else if (frequencyAIsNumber) {
    return -1;
  } else if (frequencyBIsNumber) {
    return 1;
  }
  return 0;
}

// Sort by the frequency of the base word.
function sortByLikelihood(results) {
  const resultsCopy = results.slice();
  return resultsCopy.sort((a, b) => {
    const aBase = a.base;
    const bBase = b.base;

    // First try comparing the words as-is based on their frequency.
    const strictCompare = compareFrequency(frequencyForWord[aBase], frequencyForWord[bBase]);
    if (strictCompare) {
      return strictCompare;
    }

    // If neither word is preferred as-is, then try comparing the words as suru verbs.
    const suruVerbCompare = compareFrequency(getFrequencyForSuruVerb(aBase), getFrequencyForSuruVerb(bBase));
    if (suruVerbCompare) {
      return suruVerbCompare;
    }

    // If neither word is preferred as-is or when considered as a suru verb, then prefer whichever word is shorter, if either.
    return aBase.length - bBase.length;
  });
}

function getCandidateDerivations(wordType, word) {
  /*
   * SENTENCE is a special word type that allows any
   * derivation whose conjugated word ending matches its
   * ending. So consider the entire derivation table if
   * the word type is SENTENCE.
   */
  let candidateDerivations;
  if (wordType === WordType.SENTENCE) {
    candidateDerivations = derivationTable;
  } else {
    candidateDerivations = derivationRulesForConjugatedWordType[wordType];
  }

  // Return only the derivations whose conjugated endings match the end of the word.
  return candidateDerivations.filter(derivation => word.endsWith(derivation.conjugatedEnding));
}

function derivationIsSilent(derivation) {
  return derivation.attributes && derivation.attributes.indexOf(DerivationAttribute.SILENT) !== -1;
}

function createNewDerivationSequence() {
  return {
    nonSilentDerivationsTaken: [],
    nonSilentWordFormProgression: [],
    allDerivationsTaken: [],
  };
}

function copyDerivationSequence(derivationSequence) {
  const copy = {};
  for (let key of Object.keys(derivationSequence)) {
    const array = derivationSequence[key];
    copy[key] = array.slice();
  }
  return copy;
}

function addDerivationToSequence(derivationSequence, derivation, derivedWord) {
  derivationSequence = copyDerivationSequence(derivationSequence);
  if (!derivationIsSilent(derivation)) {
    derivationSequence.nonSilentDerivationsTaken.push(derivation);
    derivationSequence.nonSilentWordFormProgression.push(derivedWord);
  }

  derivationSequence.allDerivationsTaken.push(derivation);
  return derivationSequence;
}

function createDerivationSequenceOutputForm(derivationSequence) {
  /*
   * This module works recursively from the end of the conjugated word, but
   * it makes more sense for the module's output to be in the other direction,
   * hence the reverse() calls.
   */
  return {
    derivations: derivationSequence.nonSilentDerivationsTaken.slice().reverse().map(derivation => derivation.conjugatedWordType),
    wordFormProgression: derivationSequence.nonSilentWordFormProgression.slice().reverse(),
  };
}

function unconjugateWord(word, derivation) {
  // Slice off the conjugated ending and replace it with the unconjugated ending.
  return word.substring(0, word.length - derivation.conjugatedEnding.length) + derivation.unconjugatedEnding;
}

function tookInvalidDerivationPath(derivationSequence) {
  const allDerivationsTaken = derivationSequence.allDerivationsTaken;

  /*
   * Check if any derivation in the sequence follows a sequence of derivations
   * that it's not allowed to follow.
   */
  for (let i = 0; i < allDerivationsTaken.length; ++i) {
    const derivation = allDerivationsTaken[i];
    if (!derivation.cannotFollow) {
      continue;
    }
    for (let forbiddenPredecessorSequence of derivation.cannotFollow) {
      let nextDerivationOffset = 1;

      /*
       * The forbidden predecessor sequences are expressed in forward-order in derivations.js,
       * because they are easier to think about that way. But the conjugation code works in
       * reverse order, so we have to consider the forbidden predecessor sequences in reverse
       * order also. So start at the back of the sequence.
       */
      for (let g = forbiddenPredecessorSequence.length - 1; g >= 0; --g, ++nextDerivationOffset) {
        const nextDerivation = allDerivationsTaken[i + nextDerivationOffset];
        if (!nextDerivation || nextDerivation.conjugatedWordType !== forbiddenPredecessorSequence[g]) {
          break;
        }
        if (g === 0) {
          return true; // A forbidden predecessor sequence was matched. Return true.
        }
      }
    }
  }

  return false; // No forbidden predecessor sequence was matched.
}

function unconjugateRecursive(word, wordType, derivationSequence, level, levelLimit) {
  if (tookInvalidDerivationPath(derivationSequence)) {
    return [];
  }

  if (level > levelLimit) {
    /*
     * Recursion is going too deep, abort.
     *
     * There should not be any potential for infinite recursion,
     * however it is difficult to verify with certainty that
     * there is none. Therefore, a way to break out of the
     * recursion is provided for safety (relying on running out of space
     * on the stack and throwing might take too ling)
     */
    return [];
  }

  // Check if we have reached a potentially valid result, and if so, add it to the results.
  let results = [];
  const isDictionaryForm = wordType === WordType.GODAN_VERB || wordType === WordType.ICHIDAN_VERB || wordType === WordType.SENTENCE;
  if (isDictionaryForm) {
    const derivationSequenceOutputForm = createDerivationSequenceOutputForm(derivationSequence);
    results.push({
      base: word,
      derivationSequence: derivationSequenceOutputForm,
    });
  }

  // Take possible derivation paths and recurse.
  for (let candidateDerivation of getCandidateDerivations(wordType, word)) {
    const nextDerivationSequence = addDerivationToSequence(derivationSequence, candidateDerivation, word);
    const unconjugatedWord = unconjugateWord(word, candidateDerivation);
    results = results.concat(unconjugateRecursive(unconjugatedWord, candidateDerivation.unconjugatedWordType, nextDerivationSequence, level + 1, levelLimit));
  }
  return results;
}

function removeLastCharacter(str) {
  return str.substring(0, str.length - 1);
}

module.exports.unconjugate = function(word, fuzzy, recursionDepthLimit) {
  // Handle the 'recursionDepthLimit' argument being passed as the second argument, and the 'fuzzy' argument being omitted.
  if (typeof fuzzy === typeof 1) {
    recursionDepthLimit = fuzzy;
    fuzzy = undefined;
  }

  fuzzy = !!fuzzy;
  recursionDepthLimit = recursionDepthLimit || Math.MAX_SAFE_INTEGER;
  const results = unconjugateRecursive(word, WordType.SENTENCE, createNewDerivationSequence(), 0, recursionDepthLimit);

  // If there are no results but the search should be fuzzy, chop off the last character one by one and see if we can get a substring that has results
  if (fuzzy && results.length === 0) {
    const truncatedWord = removeLastCharacter(word);
    while (truncatedWord && results.length === 0) {
      results = unconjugateRecursive(truncatedWord, WordType.SENTENCE, createNewDerivationSequence(), 0, recursionDepthLimit);
      truncatedWord = removeLastCharacter(truncatedWord);
    }
  }

  return sortByLikelihood(results);
}

module.exports.WordType = WordType;
module.exports.GrammarLinkForWordType = require('./grammar_explanations.js');
