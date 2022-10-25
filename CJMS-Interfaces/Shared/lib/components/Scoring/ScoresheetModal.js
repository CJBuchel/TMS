import React from "react";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import Calculator from "ausfll-score-calculator";
import { Button, TableCell, TableRow, TextField } from "@mui/material";
import { comm_service, initIEvent } from "@cjms_shared/services";
import { Component, Fragment } from "react";
import CloseIcon from "@mui/icons-material/Close";
import "../../assets/stylesheets/ScoresheetModal.scss";
import { CJMS_POST_SCORE, CJMS_POST_TEAM_UPDATE, CJMS_REQUEST_EVENT } from "../Requests/Request";
import Question from "./Question";
export default class ScoresheetModal extends Component {
    constructor(props) {
        super(props);
        this.state = {
            data: [],
            status: { score: 0, validationErrors: [
                    { message: `${Calculator.SuperPowered.missions.length} unanswered questions!` }
                ] },
            external_eventData: initIEvent(),
            game: Calculator.Games[0],
            publicComment: '',
            privateComment: ''
        };
        comm_service.listeners.onEventUpdate(async () => {
            CJMS_REQUEST_EVENT().then((event) => {
                this.setEventData(event);
            });
        });
        this.handleSubmit = this.handleSubmit.bind(this);
        this.setDefaults = this.setDefaults.bind(this);
        this.handleNoShow = this.handleNoShow.bind(this);
    }
    async handleScoreSubmit(score) {
        var team_update = this.props.team;
        if (this.props.existing_scoresheet) {
            score.referee = 'TM-Admin';
            score.valid_scoresheet = true;
            team_update.scores[this.props.scoresheet_index] = score;
            CJMS_POST_TEAM_UPDATE(this.props.team.team_number, team_update).then(() => {
                this.props.closeCallback();
            });
        }
        else {
            score.referee = 'TM-Admin';
            score.valid_scoresheet = true;
            CJMS_POST_SCORE(this.props.team.team_number, score).then(() => {
                this.props.closeCallback();
            });
        }
    }
    async handleNoShow() {
        var scoresheet = this.props.scoresheet;
        scoresheet.no_show = true;
        this.handleScoreSubmit(scoresheet);
    }
    async handleSubmit() {
        // Complete validation and score once more before submitting
        const val = this.state.game.validate(this.state.data);
        const sc = this.state.game.score(this.state.data);
        if (val.length > 0) {
            alert("Cannot submit score, invalid scoresheet");
            return;
        }
        var scoresheet = this.props.scoresheet;
        scoresheet.score = sc;
        scoresheet.gp = this.state.data.find((e) => e.id.startsWith("gp"))?.answer || "";
        scoresheet.scoresheet.public_comment = this.state.publicComment;
        scoresheet.scoresheet.private_comment = this.state.privateComment;
        scoresheet.scoresheet.answers = this.state.data.map(({ id, answer }) => ({ id: id, answer: answer }));
        this.handleScoreSubmit(scoresheet);
    }
    setEventData(event) {
        if (event.season != undefined && event.season != null) {
            this.setState({ external_eventData: event });
            this.setState({ game: Calculator.Games.find((game) => game.season === event.season) || Calculator.Games[0] });
        }
    }
    componentDidUpdate(prevProps, prevState, snapshot) {
        if (this.props != prevProps) {
            if (this.props.existing_scoresheet) {
                this.initData();
            }
            else {
                this.setDefaults();
            }
        }
    }
    async componentDidMount() {
        const event = await CJMS_REQUEST_EVENT();
        if (event) {
            this.setEventData(event);
            if (this.props.existing_scoresheet) {
                this.initData();
            }
            else {
                this.setDefaults();
            }
        }
    }
    setPublicComment(e) {
        this.setState({ publicComment: e });
    }
    setPrivateComment(e) {
        this.setState({ privateComment: e });
    }
    setDefaults(e) {
        if (e)
            e.preventDefault();
        const d = this.state.game.scores.map((m) => {
            return {
                ...m,
                answer: m.type === "numeric" ? `${m.defaultValue}` : m.defaultValue,
            };
        });
        this.setState({ publicComment: '', privateComment: '' });
        this.setState({ data: d });
        this.updateScore(d);
        return d;
    }
    initData() {
        const d = this.setDefaults();
        if (d) {
            const d2 = d.map((score) => ({
                ...score,
                answer: this.props.scoresheet.scoresheet.answers.find((i) => i.id === score.id)?.answer ?? score.answer
            }));
            this.setState({ publicComment: this.props.scoresheet.scoresheet.public_comment });
            this.setState({ privateComment: this.props.scoresheet.scoresheet.private_comment });
            this.setState({ data: d2 });
            this.updateScore(d2);
        }
    }
    updateScore(res) {
        const val = this.state.game.validate(res);
        const sc = this.state.game.score(res);
        const newStatus = {
            ...this.state.status,
            score: sc,
            validationErrors: val
        };
        this.setState({ status: newStatus });
    }
    setResponse(id, answer) {
        const d = this.state.data.map((r) => {
            if (r.id !== id)
                return r;
            if (Calculator.GIsNumericScore(r)) {
                return { ...r, answer };
            }
            else {
                return { ...r, answer };
            }
        });
        this.setState({ data: d });
        this.updateScore(d);
    }
    getQuestion(prefix) {
        return (this.state.game.scores
            .filter((q) => q.id.startsWith(prefix))
            .map((q) => (React.createElement(Question, { key: q.id, question: q, value: this.state.data.find((r) => r.id === q.id)?.answer, unanswered: this.state.status.validationErrors
                .map((e) => e.id)
                .join(",")
                .includes(q.id), onChange: (v) => { this.setResponse(q.id, v); }, errors: this.state.status.validationErrors
                .filter((v) => v.id && v.id.includes(q.id))
                .map((v) => v.message.replace(/^Mission \d+ - /, "")) }))));
    }
    getMissions() {
        return (React.createElement(React.Fragment, null, this.state.game.missions
            .map(({ title, prefix, image }, i) => (React.createElement(Fragment, { key: prefix },
            React.createElement(TableRow, { sx: { background: 'white' } },
                React.createElement(TableCell, { sx: i > 0 ? { borderBottom: 'none', borderTop: '1px solid', borderTopLeftRadius: '20px' } : { borderBottom: 'none', borderTopLeftRadius: '20px' }, colSpan: 2, component: "th" },
                    React.createElement("div", { style: { display: 'flex', flexDirection: 'row', alignItems: 'center' } },
                        React.createElement("img", { src: image ?? "https://www.firstlegoleague.org/sites/default/files/color/fll_theme-474df67b/fll-logo-horizontal.png", style: { marginRight: 16, height: 64, width: 'auto' } }),
                        React.createElement("h4", null, title)))),
            this.getQuestion(prefix))))));
    }
    getComments() {
        return (React.createElement("div", { style: { display: 'flex', flexDirection: 'column', background: 'white', paddingTop: 10 } },
            React.createElement(TextField, { label: "Public comment", sx: { marginBottom: 5 }, value: this.state.publicComment, onChange: (e) => this.setPublicComment(e.target.value), placeholder: "Enter a comment that the team might see - stay positive and constructive!", maxRows: 4, multiline: true }),
            React.createElement(TextField, { label: "Private comment", sx: { marginBottom: 5 }, value: this.state.privateComment, onChange: (e) => this.setPrivateComment(e.target.value), placeholder: "Enter a comment for other referees/judges - the team cannot see this one.", maxRows: 4, multiline: true })));
    }
    render() {
        if (!this.props.display)
            return (React.createElement(React.Fragment, null));
        return (React.createElement("div", { className: "ScoresheetModal" },
            React.createElement(Button, { startIcon: React.createElement(CloseIcon, null), variant: "outlined", sx: {
                    width: '90%',
                    marginBottom: '1%',
                    marginTop: '1%',
                    color: 'white',
                    borderColor: 'white'
                }, onClick: () => { this.props.closeCallback(); } }, "Close"),
            React.createElement("div", { className: "scoresheet-mission" },
                React.createElement(Table, null,
                    React.createElement(TableBody, null, this.getMissions())),
                this.getComments()),
            React.createElement("div", { className: "challenge-buttons" },
                React.createElement(Button, { variant: "outlined", sx: {
                        color: 'orange',
                        borderColor: 'orange'
                    }, onClick: () => { this.handleNoShow(); } }, "No Show"),
                React.createElement(Button, { variant: "outlined", sx: {
                        color: 'red',
                        borderColor: 'red',
                    }, onClick: () => { this.setDefaults(); } }, "Clear")),
            React.createElement("div", { className: "challenge-buttons" },
                React.createElement(Button, { variant: "contained", sx: {
                        backgroundColor: 'green',
                        color: 'white',
                        borderColor: 'green'
                    }, onClick: () => { this.handleSubmit(); }, disabled: this.state.status.validationErrors.length > 0 }, "Submit"))));
    }
}
