/// <reference types="react" />
import { Score, ScoreAnswer } from "ausfll-score-calculator/dist/game-types";
declare type BaseProps = {
    question: Score;
    value?: ScoreAnswer["answer"];
    unanswered: boolean;
    onChange?: (v: ScoreAnswer["answer"]) => void;
    errors?: string[];
};
export declare const Question: ({ question, value, errors, ...rest }: BaseProps) => JSX.Element;
export default Question;
