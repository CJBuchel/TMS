import React from "react";
import { Score, ScoreError, ScoreResult, Game } from "ausfll-score-calculator/dist/game-types";
import { IEvent, ITeam, ITeamScore } from "@cjms_shared/services";
import { Component } from "react";
import "../../assets/stylesheets/ScoresheetModal.scss";
type Status = {
    score: number;
    validationErrors: ScoreError[];
};
interface IProps {
    display: boolean;
    existing_scoresheet: boolean;
    team: ITeam;
    scoresheet: ITeamScore;
    scoresheet_index: number;
    closeCallback: Function;
}
interface IState {
    data: ScoreResult[];
    status: Status;
    external_eventData: IEvent;
    game: Game;
    publicComment: string;
    privateComment: string;
}
export default class ScoresheetModal extends Component<IProps, IState> {
    constructor(props: any);
    handleScoreSubmit(score: ITeamScore): Promise<void>;
    handleNoShow(): Promise<void>;
    handleSubmit(): Promise<void>;
    setEventData(event: IEvent): void;
    componentDidUpdate(prevProps: Readonly<IProps>, prevState: Readonly<IState>, snapshot?: any): void;
    componentDidMount(): Promise<void>;
    setPublicComment(e: string): void;
    setPrivateComment(e: string): void;
    setDefaults(e?: React.MouseEvent<HTMLButtonElement>): ScoreResult[] | undefined;
    initData(): void;
    updateScore(res: ScoreResult[]): void;
    setResponse(id: Score["id"], answer: ScoreResult["answer"]): void;
    getQuestion(prefix: string): JSX.Element[];
    getMissions(): JSX.Element;
    getComments(): JSX.Element;
    render(): JSX.Element;
}
export {};
