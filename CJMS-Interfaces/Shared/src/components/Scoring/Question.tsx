import React, { useEffect, useState } from "react";
import Calculator, {CategoricalScore, NumericScore, Score, ScoreAnswer} from "@ausfll/ausfll-score-calculator";

import { createStyles, makeStyles } from "@mui/styles";
import { Theme } from "@mui/material/styles";
import TextField from "@mui/material/TextField";
import TableRow from "@mui/material/TableRow";
import TableCell from "@mui/material/TableCell";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
// import Tooltip from "@mui/material/Tooltip";

type BaseProps = {
  question: Score;
  value?: ScoreAnswer["answer"];
  unanswered: boolean;
  onChange?: (v: ScoreAnswer["answer"]) => void;
  errors?: string[];
}

type NumericProps = BaseProps & {
  question: NumericScore;
}



const NumericQuestion = ({question, value, errors, onChange}: NumericProps) => {
  const classes = useStyles();
  return (
    <TableRow className={classes.questions}>
      <TableCell
        className={[
          classes.noborder,
          classes.label,
          errors?.length ? classes.errorLabel : "",
        ].join(" ")}
      >
        <div className={classes.col}>
          <span>{question.label}</span>
          {errors?.map((e, i) => (
            <span key={i}>{e}</span>
          ))}
        </div>
      </TableCell>
      <TableCell className={[classes.noborder, classes.options].join(" ")}>
        {onChange ? (
          <TextField
            type="number"
            value={Number(value) ?? question.defaultValue}
            InputProps={{
              inputProps: { max: question.max, min: question.min },
            }}
            onChange={(e) => onChange(e.target.value)}
          />
        ) : (
          <span>{value ?? "?"}</span>
        )}
      </TableCell>
    </TableRow>
  );
}

type CategoricalProps = BaseProps & {
  question: CategoricalScore;
}

const CategoricalQuestion = ({question, value, onChange, errors}: CategoricalProps) => {
  const [val, setVal] = useState<string | undefined>(value);

  const handleChange = (s: string) => {
    if (!onChange) return;
    setVal(s);
    onChange(s);
  }

  useEffect(() => {
    setVal(value);
  }, [value]);

  const classes = useStyles();

  return (
    <TableRow className={classes.questions}>
      <TableCell
        className={[
          classes.noborder,
          classes.label,
          errors?.length ? classes.errorLabel : "",
        ].join(" ")}
      >
        <div className={classes.col}>
          <span>{question.label}</span>
        </div>
      </TableCell>
      <TableCell className={[classes.noborder, classes.options].join(" ")}>
        <RadioGroup
          row
          value={val ?? null}
          onChange={(e) => (onChange ? handleChange(e.target.value) : {})}
        >
          {question.options.map((opt, key) => (
            <FormControlLabel
              key={key}
              value={opt}
              control={<Radio />}
              label={String(opt).replace(/_/g, " ")}
            />
          ))}
        </RadioGroup>
      </TableCell>
    </TableRow>
  );
}

export const Question = ({question, value, errors, ...rest}: BaseProps) => {
  return Calculator.GIsCategoricalScore(question) ? (
    <CategoricalQuestion
      question={question}
      value={value}
      errors={errors?.filter((x,i,a) => a.indexOf(x) === i)}
      {...rest}
    />
  ) : (
    <NumericQuestion
      question={question}
      value={value}
      errors={errors?.filter((x, i, a) => a.indexOf(x) === i)}
      {...rest}
    />
  );
}

const useStyles = makeStyles((theme:Theme) =>
  createStyles({
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
  })
);
