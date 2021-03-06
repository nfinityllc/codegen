@import "../../../../styles/base.scss";
.user-picture {
    text-align: center;
    font-size: 15px;
    height: 32px;
    width: 32px;
    line-height: 32px;
    padding: 0;
    margin: 0 2px 0 0;
    overflow: hidden;
    color: #ffffff;
    background: $fc-accent-color no-repeat center center;
    background-size: 32px 32px;
    cursor: pointer;
    border: 1px solid transparent;
}

.user-picture.no-picture {
    border-color: $fc-accent-color;
}

.user-picture span {
    visibility: hidden;
}

.user-picture.more {
    background-color: #6fc2d7;
    color: #f6f6f6;
}

.user-picture.add {
    background-color: #6fc2d7;
    color: #f6f6f6;
    font-size: 20px;
    margin-left: 5px;
}

.user-picture:hover span, .user-picture.no-picture span, .user-picture.more span, .user-picture.add span {
    visibility: visible;
}

.user-picture.no-picture:hover {
    border-color: #32a3c0;
}