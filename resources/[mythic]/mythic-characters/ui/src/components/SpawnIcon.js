/* eslint-disable react/prop-types */
import React, { useEffect, useState } from 'react';
import { connect } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { selectSpawn, spawnToWorld } from '../actions/characterActions';
import { Tooltip } from '@mui/material';

const SpawnIcon = (props) => {
    const useStyles = makeStyles((theme) => ({
        newPoint: {
            width: '1%',
            height: '1vh',
            display: 'flex',
            position: 'absolute',
            minWidth: 0,
            textAlign: 'center',
            transition: 'transform .2s ease-in-out',
            '&:hover': {
                transform: 'scale(1.1)',
                cursor: 'pointer'
            }
        },
        icon: {
            stroke: 'black',
            strokeWidth: 10,
            opacity: 0.7,
            fontSize: 26,
            '&.selected': {
                opacity: 1,
                fontSize: 34
            },
            transition: 'ease-in-out font-size 0.25s'
        }
    }));

    const classes = useStyles();

    const onClick = () => {
        if (props?.selectedSpawn?.id === props.spawn.id) {
            props.spawnToWorld(props.selectedSpawn, props.selectedChar);
        } else {
            props.selectSpawn(props.spawn);
        }
    };

    return (
        <div
            key={props.spawn.label}
            className={classes.newPoint}
            style={{
                marginTop: props.spawn.posX,
                marginLeft: props.spawn.posY,
            }}
        >
            <Tooltip
                title={props.spawn.label}
                placement={'top'}
                open={props?.selectedSpawn?.id === props.spawn.id}
                arrow
            >
                <div>
                    <FontAwesomeIcon
                        className={`${classes.icon} ${props?.selectedSpawn?.id === props.spawn.id ? ' selected' : ''}`}
                        icon={props.spawn.icon ? props.spawn.icon : 'fas fa-location-dot'}
                        color={props.spawn.label === 'Boring Tower' ? '#BE0B22' : '#a1de01'}
                        onClick={onClick}
                        onMouseEnter={() => props.selectSpawn(props.spawn)}
                        onMouseLeave={() => props.selectSpawn({})}
                    />
                </div>
            </Tooltip>
        </div>
    );
};

const mapStateToProps = (state) => ({
    selected: state.characters.selected,
    selectedSpawn: state.spawn.selected,
    selectedChar: state.characters.selected,
});

export default connect(mapStateToProps, { selectSpawn, spawnToWorld })(SpawnIcon);
