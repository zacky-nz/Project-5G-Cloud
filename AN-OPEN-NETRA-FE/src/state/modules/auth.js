import axios from 'axios';

// URL API Backend
const API_URL = process.env.VUE_APP_API_URL || 'http://172.20.0.7:30000';

export const state = {
    currentUser: localStorage.getItem('user') ? JSON.parse(localStorage.getItem('user')) : null,
}

export const mutations = {
    SET_CURRENT_USER(state, newValue) {
        state.currentUser = newValue;
        if (newValue) {
            localStorage.setItem('user', JSON.stringify(newValue));
        } else {
            localStorage.removeItem('user');
            localStorage.removeItem('jwt');
            localStorage.removeItem('refresh_token');
        }
    }
}

export const getters = {
    loggedIn(state) {
        return !!state.currentUser;
    }
}

export const actions = {
    // --- PERBAIKAN DISINI: Hapus '{ state }' jadi kosong '()' ---
    init() {
        const token = localStorage.getItem('jwt');
        if (token) {
            axios.defaults.headers.common['Authorization'] = 'Bearer ' + token;
        }
    },

    // --- FUNGSI LOGIN ---
    logIn({ commit }, { email, password } = {}) {
        return axios.post(`${API_URL}/api/token/`, {
            username: email,
            password: password
        }).then((response) => {
            const accessToken = response.data.access;
            const refreshToken = response.data.refresh;

            localStorage.setItem('jwt', accessToken);
            localStorage.setItem('refresh_token', refreshToken);

            axios.defaults.headers.common['Authorization'] = 'Bearer ' + accessToken;

            const user = {
                uid: 1,
                username: 'Admin',
                email: email,
                token: accessToken
            };

            commit('SET_CURRENT_USER', user);
            return user;
        }).catch((error) => {
            console.error("Login Error:", error);
            throw error;
        });
    },

    // --- FUNGSI LOGOUT ---
    logOut({ commit }) {
        commit('SET_CURRENT_USER', null);
        delete axios.defaults.headers.common['Authorization'];
        return Promise.resolve(true);
    },

    // Tambahkan komen eslint-disable agar tidak error karena variable tidak dipakai
    // eslint-disable-next-line no-unused-vars
    register({ commit, dispatch, getters }, { username, email, password } = {}) {
        return Promise.reject("Register disabled");
    },

    // eslint-disable-next-line no-unused-vars
    resetPassword({ commit, dispatch, getters }, { email } = {}) {
        return Promise.reject("Reset Password disabled");
    },

    validate({ state }) {
        return Promise.resolve(state.currentUser);
    },
}

// import { getFirebaseBackend } from '../../authUtils.js'

// export const state = {
//     currentUser: sessionStorage.getItem('authUser'),
// }

// export const mutations = {
//     SET_CURRENT_USER(state, newValue) {
//         state.currentUser = newValue
//         saveState('auth.currentUser', newValue)
//     }
// }

// export const getters = {
//     // Whether the user is currently logged in.
//     loggedIn(state) {
//         return !!state.currentUser
//     }
// }

// export const actions = {
//     // This is automatically run in `src/state/store.js` when the app
//     // starts, along with any other actions named `init` in other modules.
//     // eslint-disable-next-line no-unused-vars
//     init({ state, dispatch }) {
//         dispatch('validate')
//     },

//     // Logs in the current user.
//     logIn({ commit, dispatch, getters }, { email, password } = {}) {
//         if (getters.loggedIn) return dispatch('validate')

//         return getFirebaseBackend().loginUser(email, password).then((response) => {
//             const user = response
//             commit('SET_CURRENT_USER', user)
//             return user
//         });
//     },

//     // Logs out the current user.
//     logOut({ commit }) {
//         // eslint-disable-next-line no-unused-vars
//         commit('SET_CURRENT_USER', null)
//         return new Promise((resolve, reject) => {
//             // eslint-disable-next-line no-unused-vars
//             getFirebaseBackend().logout().then((response) => {
//                 resolve(true);
//             }).catch((error) => {
//                 reject(this._handleError(error));
//             })
//         });
//     },

//     // register the user
//     register({ commit, dispatch, getters }, { username, email, password } = {}) {
//         if (getters.loggedIn) return dispatch('validate')

//         return getFirebaseBackend().registerUser(username, email, password).then((response) => {
//             const user = response
//             commit('SET_CURRENT_USER', user)
//             return user
//         });
//     },

//     // register the user
//     // eslint-disable-next-line no-unused-vars
//     resetPassword({ commit, dispatch, getters }, { email } = {}) {
//         if (getters.loggedIn) return dispatch('validate')

//         return getFirebaseBackend().forgetPassword(email).then((response) => {
//             const message = response.data
//             return message
//         });
//     },

//     // Validates the current user's token and refreshes it
//     // with new data from the API.
//     // eslint-disable-next-line no-unused-vars
//     validate({ commit, state }) {
//         if (!state.currentUser) return Promise.resolve(null)
//         const user = getFirebaseBackend().getAuthenticatedUser();
//         commit('SET_CURRENT_USER', user)
//         return user;
//     },
// }

// // ===
// // Private helpers
// // ===

// function saveState(key, state) {
//     window.sessionStorage.setItem(key, JSON.stringify(state))
// }
