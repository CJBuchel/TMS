import React, { useEffect, useState } from "react";
import Calculator from "@ausfll/ausfll-score-calculator";
import { createStyles, makeStyles } from "@mui/styles";
import TextField from "@mui/material/TextField";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
const NumericQuestion = ({ question, value, errors, onChange }) => {
    const classes = useStyles();
    return (React.createElement(TableRow, { className: classes.questions },
        React.createElement(TableCell, { className: [
                classes.noborder,
                classes.label,
                errors?.length ? classes.errorLabel : "",
            ].join(" ") },
            React.createElement("div", { className: classes.col },
                React.createElement("span", null, question.label),
                errors?.map((e, i) => (React.createElement("span", { key: i }, e))))),
        React.createElement(TableCell, { className: [classes.noborder, classes.options].join(" ") }, onChange ? (React.createElement(TextField, { type: "number", value: Number(value) ?? question.defaultValue, InputProps: {
                inputProps: { max: question.max, min: question.min },
            }, onChange: (e) => onChange(e.target.value) })) : (React.createElement("span", null, value ?? "?")))));
};
const CategoricalQuestion = ({ question, value, onChange, errors }) => {
    const [val, setVal] = useState(value);
    const handleChange = (s) => {
        if (!onChange)
            return;
        setVal(s);
        onChange(s);
    };
    useEffect(() => {
        setVal(value);
    }, [value]);
    const classes = useStyles();
    return (React.createElement(TableRow, { className: classes.questions },
        React.createElement(TableCell, { className: [
                classes.noborder,
                classes.label,
                errors?.length ? classes.errorLabel : "",
            ].join(" ") },
            React.createElement("div", { className: classes.col },
                React.createElement("span", null, question.label))),
        React.createElement(TableCell, { className: [classes.noborder, classes.options].join(" ") },
            React.createElement(RadioGroup, { row: true, value: val ?? null, onChange: (e) => (onChange ? handleChange(e.target.value) : {}) }, question.options.map((opt, key) => (React.createElement(FormControlLabel, { key: key, value: opt, control: React.createElement(Radio, null), label: String(opt).replace(/_/g, " ") })))))));
};
export const Question = ({ question, value, errors, ...rest }) => {
    return Calculator.GIsCategoricalScore(question) ? (React.createElement(CategoricalQuestion, { question: question, value: value, errors: errors?.filter((x, i, a) => a.indexOf(x) === i), ...rest })) : (React.createElement(NumericQuestion, { question: question, value: value, errors: errors?.filter((x, i, a) => a.indexOf(x) === i), ...rest }));
};
const useStyles = makeStyles((theme) => createStyles({
    questions: {},
    noborder: {
        border: "none",
    },
    options: {
        display: "flex",
        flexWrap: "wrap",
    },
    label: {},
    labelflex: {
        alignItems: "center",
        display: "flex",
    },
    labelerror: {
        alignItems: "center",
        display: "flex",
        color: "red",
    },
    errorLabel: {
        fontWeight: "bold",
        color: theme.palette.error.main,
    },
    numq: {
        minWidth: 80,
        marginRight: 8,
    },
    col: {
        display: "flex",
        flexDirection: "column",
        alignItems: "flex-start",
    },
    selectedOption: {
        backgroundColor: theme.palette.success.light,
        borderBottom: "2px solid " + theme.palette.success.dark,
        cursor: "pointer",
        padding: 16,
        borderRadius: 32,
        margin: 4,
        textTransform: "capitalize",
        fontWeight: "bold",
    },
    option: {
        backgroundColor: theme.palette.grey[200],
        cursor: "pointer",
        borderBottom: "2px solid " + theme.palette.primary.main,
        // paddingBottom: 1,
        padding: 16,
        borderRadius: 32,
        margin: 4,
        textTransform: "capitalize",
    },
}));
