import { useState } from "react";

export default function useScorer() {
  const getScorer = () => {
    const scorerString:any = sessionStorage.getItem('scorer');
    const userScorer = JSON.parse(scorerString);
    if (userScorer && userScorer.scorer) {
      return userScorer.scorer;
    }
  }

  const [scorer, setScorer] = useState(getScorer());
  const saveScorer = (valueScorer:string) => {
    sessionStorage.setItem('scorer', JSON.stringify(valueScorer));
    setScorer(valueScorer);
  }

  return { setScorer: saveScorer, scorer }
}