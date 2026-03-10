import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Grid, List, Alert } from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Unit from './Unit';

const useStyles = makeStyles((theme) => ({
    wrapper: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-end',
        height: 'calc(100% - 40px)',
    },
    title: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        background: `${theme.palette.secondary.dark}CC`,
        cursor: 'pointer',
        '& h3': {
            height: '100%',
            padding: '0 15px',
            marginBlockEnd: 0,
            '& small': {
                fontSize: 15,
                color: theme.palette.text.alt,
                fontWeight: 400,
            },
        },
        '& span': {
            transition: 'all 0.25s ease-in-out',
            margin: '0 10px',
        },
    },
    list: {
        background: `${theme.palette.secondary.dark}CC`,
        overflow: 'auto',
        padding: 0,
        transition: 'all 0.25s linear',
    },
    alert: {
        width: 'fit-content',
        margin: 'auto',
    },
}));

const typeNames = {
    police: "Police",
    ems: "EMS",
    prison: "DOC",
    tow: "Tow",
};

export default function RosterSection({ width, type, units, fullHeight }) {
    const classes = useStyles();
    const dispatch = useDispatch();
    const tName = typeNames[type] ?? type?.toUpperCase() ?? "UNKNOWN";

    const expanded = useSelector((state) => state.alerts.rosterSections)?.[type];

    // Default to empty array if not an array
    const typeUnits = Array.isArray(units) ? units : [];

    // 🐞 Debug: Show units passed to this section
    // console.log(`[DEBUG] RosterSection (${type}) received units:`, typeUnits);

    const expandRoster = () => {
        dispatch({
            type: 'TOGGLE_ROSTER_SECTION',
            payload: { type },
        });
    };

    return (
        <Grid item xs={width} className={classes.wrapper} style={{ height: fullHeight ? "100%" : null }}>
            <div className={classes.title} onClick={expandRoster}>
                <h3>
                    {tName}
                    {typeUnits.length > 0 && (
                        <small>
                            {' - On Duty: '}
                            <b>{typeUnits.length}</b>
                        </small>
                    )}
                    {(type === "police" || type === "ems") && typeUnits.length > 0 && (
                        <small>
                            {`  (${typeUnits.length} ${typeUnits.length === 1 ? "Unit" : "Units"})`}
                        </small>
                    )}
                </h3>
                <span style={{ transform: expanded ? "rotateZ(180deg)" : "rotateZ(0deg)" }}>
                    <FontAwesomeIcon icon={['fas', 'chevron-up']} />
                </span>
            </div>

            <List
                className={classes.list}
                style={{
                    maxHeight: expanded ? "85%" : "0%",
                    minHeight: expanded ? "85%" : "0%",
                    padding: expanded ? "10px 0" : "0"
                }}
            >
                {typeUnits.length > 0 ? (
                    typeUnits
                        .filter(unit => unit) // Add this filter to remove undefined units
                        .sort((a, b) => (a?.primary || 0) - (b?.primary || 0))
                        .map((unit, k) => {
                            try {
                                return (
                                    <Unit
                                        key={`unit-${k}`}
                                        unitData={unit}
                                        unitType={type}
                                        missingCallsign={unit?.primary == null}
                                    />
                                );
                            } catch (err) {
                                console.error(`Error rendering unit at index ${k}:`, err, unit);
                                return null;
                            }
                        })
                ) : (
                    <Alert className={classes.alert} variant="outlined" severity="info">
                        No {tName} On Duty
                    </Alert>
                )}
            </List>
        </Grid>
    );
}
