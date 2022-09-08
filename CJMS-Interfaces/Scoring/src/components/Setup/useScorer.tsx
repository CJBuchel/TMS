import { useState } from "react";

export default function useScorer() {
  const getScorer = () => {
    const scorerString:any = sessionStorage.getItem('scorer');
    const valueScorer = JSON.parse(scorerString);
    if (valueScorer && valueScorer.scorer) {
      return valueScorer.scorer;
    }
  }

  const [scorer, setScorer] = useState(getScorer());
  const saveScorer = (valueScorer:any) => {
    sessionStorage.setItem('scorer', JSON.stringify(valueScorer));
    setScorer(valueScorer.scorer);
  }

  return { setScorer: saveScorer, scorer }
}