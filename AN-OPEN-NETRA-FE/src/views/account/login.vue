<script>
import {
  required,
  helpers
} from "@vuelidate/validators";
import axios from 'axios';

import {
  authMethods,
  authFackMethods,
  notificationMethods,
} from "@/state/helpers";


export default {
  data() {
    return {
      email: "",
      password: "",
      submitted: false,
      authError: null,
      tryingToLogIn: false,
      isAuthError: false,
      processing: false,
    };
  },
  validations: {
  email: {
    required: helpers.withMessage("Username is required", required),
    },
  password: {
    required: helpers.withMessage("Password is required", required),
    },
  },

  computed: {

  },
  methods: {
    ...authMethods,
    ...authFackMethods,
    ...notificationMethods,

    async signinapi() {
    try {
      this.processing = true;
      this.authError = null;

      const result = await axios.post('http://172.20.0.7:30000/api/token/', 
        {
        username: this.email,
        password: this.password
      });

      localStorage.setItem('access', result.data.access);
      localStorage.setItem('refresh', result.data.refresh);
      localStorage.setItem('user', JSON.stringify({ username: this.email }));

      axios.defaults.headers.common['Authorization'] = 
      'Bearer ' + result.data.access;

      this.processing = false;

      // REDIRECT
      this.$router.push({ path: '/' }); 

    } catch (err) {
      console.log("LOGIN ERROR:", err);
      this.authError = "Username atau password salah / backend unreachable";
      this.processing = false;
    }
  }

    // async signinapi() {
    //   this.processing = true;
    //   const result = await axios.post('http://127.0.0.1:8000/api/token/', {
    //     username: this.email,
    //     password: this.password
    //   });
    //   if (result.data.status == 'errors') {
    //     return this.authError = result.data.data;
    //   }
    //   localStorage.setItem('jwt', result.data.token);
    //   this.$router.push({
    //     path: '/'
    //   });
    // },

    // Try to log the user in with the username
    // and password they provided.
    // tryToLogIn() {
    //   this.processing = true;
    //   this.submitted = true;
    //   // stop here if form is invalid
    //   this.$touch;

    //   if (this.$invalid) {
    //     return;
    //   } else {
    //     if (process.env.VUE_APP_DEFAULT_AUTH === "firebase") {
    //       this.tryingToLogIn = true;
    //       // Reset the authError if it existed.
    //       this.authError = null;
    //       return (
    //         this.logIn({
    //           email: this.email,
    //           password: this.password,
    //         })
    //           // eslint-disable-next-line no-unused-vars
    //           .then((token) => {
    //             this.tryingToLogIn = false;
    //             this.isAuthError = false;
    //             // Redirect to the originally requested page, or to the home page
    //             this.$router.push({
    //               path: '/'
    //             });
    //           })
    //           .catch((error) => {
    //             this.tryingToLogIn = false;
    //             this.authError = error ? error : "";
    //             this.isAuthError = true;
    //             this.processing = false;
    //           })
    //       );
    //     } else if (process.env.VUE_APP_DEFAULT_AUTH === "fakebackend") {
    //       const { email, password } = this;
    //       if (email && password) {
    //         this.login({
    //           email,
    //           password,
    //         });
    //       }
    //     } else if (process.env.VUE_APP_DEFAULT_AUTH === "authapi") {
    //       axios
    //         .post("http://127.0.0.1:8000/api/login", {
    //           email: this.email,
    //           password: this.password,
    //         })
    //         .then((res) => {
    //           return res;
    //         });
    //     }
    //   }
    // },

  },
};
</script>

<template>
  <div class="auth-page-wrapper auth-bg-cover py-5 d-flex justify-content-center align-items-center min-vh-100">
      <div class="bg-overlay"></div>
      <!-- <div class="shape">
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1440 120">
        <path d="M 0,36 C 144,53.6 432,123.2 720,124 C 1008,124.8 1296,56.8 1440,40L1440 140L0 140z"></path>
        </svg>
      </div> -->

      <div class="auth-page-content overflow-hidden pt-lg-5">
          <BContainer>
              <BRow>
                  <BCol lg="12">
                      <BCard no-body class="overflow-hidden">
                          <BRow class="g-0">
                              <BCol lg="6">
                                  <div class="p-lg-5 p-4 auth-one-bg align-items-center h-100"> 
                                      <!-- <div class="bg-overlay"></div> -->
                                      <div class="position-relative h-100 d-flex flex-column">
                                          <div class="mb-4">
                                              <router-link to="/" class="d-block">
                                                  <img src="@/assets/images/netra-logo.png" alt="" width="135" height="30" class="center logosize">
                                              </router-link>
                                          </div>
                                          <!-- <div class="mt-auto">
                                              <div class="mb-3">
                                                  <i class="ri-double-quotes-l display-4 text-success"></i>
                                              </div>

                                              <div id="qoutescarouselIndicators" class="carousel slide"
                                                  data-bs-ride="carousel">
                                                  <Swiper class=" text-center text-white-50 pb-5"
                                                      :autoplay="{ delay: 3000, disableOnInteraction: false }"
                                                      :loop="true" :modules="[Autoplay, Navigation, Pagination]"
                                                      :pagination="{ clickable: true, el: '.swiper-pagination' }">
                                                      <swiper-slide>
                                                          <div class="active">
                                                              <p class="fs-15 fst-italic">" Great! Clean code, clean
                                                                  design, easy for customization. Thanks very much! "</p>
                                                          </div>
                                                      </swiper-slide>
                                                      <swiper-slide>
                                                          <div>
                                                              <p class="fs-15 fst-italic">" The theme is really great with
                                                                  an amazing customer support."</p>
                                                          </div>
                                                      </swiper-slide>
                                                      <swiper-slide>
                                                          <div>
                                                              <p class="fs-15 fst-italic">" Great! Clean code, clean
                                                                  design, easy for customization. Thanks very much! "</p>
                                                          </div>
                                                      </swiper-slide>
                                                      <div class="swiper-pagination"></div>
                                                  </Swiper> 
                                              </div>
                                          </div> -->
                                      </div>
                                  </div>
                              </BCol>

                              <BCol lg="6">
                                  <div class="p-lg-5 p-4">
                                      <div>
                                          <h5 class="text-primary">Welcome Back !</h5>
                                          <p class="text-muted">Sign in to continue to Open Netra.</p>
                                      </div>

                                      <div class="mt-4">
                                          <b-alert v-model="authError" variant="danger" class="mt-3" dismissible>
                                            {{ authError }}
                                          </b-alert>

                                          <form @submit.prevent="signinapi">
                                              <div class="mb-3">
                                                  <label for="username" class="form-label">Username</label>
                                                  <input type="text" class="form-control" id="username"
                                                    placeholder="Enter username" v-model="email" />
                                                  <div class="invalid-feedback">
                                                    <span></span>
                                                  </div>
                                              </div>

                                              <div class="mb-3">
                                                  <div class="float-end">
                                                      <router-link to="/forgot-password" class="text-muted">
                                                          Forgot password?
                                                      </router-link>
                                                  </div>

                                                  <label class="form-label" for="password-input">Password</label>
                                                  <div class="position-relative auth-pass-inputgroup mb-3">
                                                      <input type="password" v-model="password"
                                                          class="form-control pe-5" placeholder="Enter password"
                                                          id="password-input" />  
                                                      <BButton variant="link"
                                                          class="position-absolute end-0 top-0 text-decoration-none text-muted"
                                                          type="button" id="password-addon">
                                                          <i class="ri-eye-fill align-middle"></i>
                                                      </BButton>
                                                      <div class="invalid-feedback">
                                                        <span></span>
                                                      </div>
                                                  </div>
                                              </div>

                                              <div class="form-check">
                                                  <input class="form-check-input" type="checkbox" value=""
                                                      id="auth-remember-check">
                                                  <label class="form-check-label" for="auth-remember-check">Remember
                                                      me</label>
                                              </div>

                                              <div class="mt-4">
                                                  <BButton variant="success" class="w-100" type="submit" :disabled="processing">
                                                    {{ processing ? "Please wait" : "Sign In" }}
                                                  </BButton>
                                              </div>

                                              <!-- <div class="mt-4 text-center">
                                                  <div class="signin-other-title">
                                                      <h5 class="fs-13 mb-4 title">Sign In with</h5>
                                                  </div>

                                                  <div>
                                                      <BButton type="button" variant="primary" class="btn-icon"><i
                                                              class="ri-facebook-fill fs-16"></i></BButton>
                                                      <BButton type="button" variant="danger" class="btn-icon ms-1"><i
                                                              class="ri-google-fill fs-16"></i></BButton>
                                                      <BButton type="button" variant="dark" class="btn-icon ms-1"><i
                                                              class="ri-github-fill fs-16"></i></BButton>
                                                      <BButton type="button" variant="info" class="btn-icon ms-1"><i
                                                              class="ri-twitter-fill fs-16"></i></BButton>
                                                  </div>
                                              </div> -->

                                          </form>
                                      </div>

                                      <!-- <div class="mt-5 text-center">
                                          <p class="mb-0">Don't have an account ? <router-link to="/register"
                                                  class="fw-semibold text-primary text-decoration-underline"> Signup
                                              </router-link>
                                          </p>
                                      </div> -->
                                  </div>
                              </BCol>
                          </BRow>
                      </BCard>
                  </BCol>
              </BRow>
          </BContainer>
      </div>

      <footer class="footer">
          <BContainer>
              <BRow>
                  <BCol lg="12">
                      <div class="text-center">
                          <p class="mb-0">&copy; {{ new Date().getFullYear() }} Telecom Infra Project 
                            <!-- <i class="mdi mdi-heart text-danger"></i> by Themesbrand -->
                          </p>
                      </div>
                  </BCol>
              </BRow>
          </BContainer>
      </footer>
  </div>
</template>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Public+Sans:wght@300;400;500;600;700&display=swap');
  
</style>

<!-- <template>
  <div class="auth-page-wrapper pt-5">
    <div class="auth-one-bg-position auth-one-bg" id="auth-particles">
      <div class="bg-overlay"></div>

      <div class="shape">

        <svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink"
          viewBox="0 0 1440 120">
          <path d="M 0,36 C 144,53.6 432,123.2 720,124 C 1008,124.8 1296,56.8 1440,40L1440 140L0 140z"></path>
        </svg>
      </div>
    </div>

    <div class="auth-page-content">
      <BContainer>
        <BRow>
          <BCol lg="12">
            <div class="text-center mt-sm-5 mb-4 text-white-50">
              <div>
                <router-link to="/" class="d-inline-block auth-logo">
                  <img src="@/assets/images/logo-light.png" alt="" height="20" />
                </router-link>
              </div>
              <p class="mt-3 fs-15 fw-medium">
                Premium Admin & Dashboard Template
              </p>
            </div>
          </BCol>
        </BRow>

        <BRow class="justify-content-center">
          <BCol md="8" lg="6" xl="5">
            <BCard no-body class="mt-4">
              <BCardBody class="p-4">
                <div class="text-center mt-2">
                  <h5 class="text-primary">Welcome Back !</h5>
                  <p class="text-muted">Sign in to continue to Velzon.</p>
                </div>
                <div class="p-2 mt-4">
                  <b-alert v-model="authError" variant="danger" class="mt-3" dismissible>{{ authError }}</b-alert>

                  <div>

                  </div>

                  <form @submit.prevent="tryToLogIn">
                    <div class="mb-3">
                      <label for="email" class="form-label">Email</label>
                      <input type="email" class="form-control" id="email" placeholder="Enter email" v-model="email" />
                      <div class="invalid-feedback">
                        <span></span>
                      </div>
                    </div>

                    <div class="mb-3">
                      <div class="float-end">
                        <router-link to="/forgot-password" class="text-muted">Forgot
                          password?</router-link>
                      </div>
                      <label class="form-label" for="password-input">Password</label>
                      <div class="position-relative auth-pass-inputgroup mb-3">
                        <input type="password" v-model="password" class="form-control pe-5" placeholder="Enter password"
                          id="password-input" />
                        <BButton variant="link" class="position-absolute end-0 top-0 text-decoration-none text-muted"
                          type="button" id="password-addon">
                          <i class="ri-eye-fill align-middle"></i>
                        </BButton>
                        <div class="invalid-feedback">
                          <span></span>
                        </div>
                      </div>
                    </div>

                    <div class="form-check">
                      <input class="form-check-input" type="checkbox" value="" id="auth-remember-check" />
                      <label class="form-check-label" for="auth-remember-check">Remember
                        me</label>
                    </div>

                    <div class="mt-4">
                      <BButton variant="success" class="w-100" type="submit" @click="signinapi" :disabled="processing">
                        {{ processing ? "Please wait" : "Sign In" }}
                      </BButton>
                    </div>

                    <div class="mt-4 text-center">
                      <div class="signin-other-title">
                        <h5 class="fs-13 mb-4 title">Sign In with</h5>
                      </div>
                      <div>
                        <BButton variant="primary" type="button" class="btn btn-primary btn-icon">
                          <i class="ri-facebook-fill fs-16"></i>
                        </BButton>
                        <BButton variant="danger" type="button" class="btn btn-danger btn-icon ms-1">
                          <i class="ri-google-fill fs-16"></i>
                        </BButton>
                        <BButton variant="dark" type="button" class="btn btn-dark btn-icon ms-1">
                          <i class="ri-github-fill fs-16"></i>
                        </BButton>
                        <BButton variant="info" type="button" class="btn btn-info btn-icon ms-1">
                          <i class="ri-twitter-fill fs-16"></i>
                        </BButton>
                      </div>
                    </div>
                  </form>
                </div>
              </BCardBody>
            </BCard>

            <div class="mt-4 text-center">
              <p class="mb-0">
                Don't have an account ?
                <router-link to="/register" class="fw-semibold text-primary
                  text-decoration-underline">
                  Signup
                </router-link>
              </p>
            </div>
          </BCol>
        </BRow>
      </BContainer>
    </div>

    <footer class="footer">
      <BContainer>
        <BRow>
          <BCol lg="12">
            <div class="text-center">
              <p class="mb-0 text-muted">
                &copy; {{ new Date().getFullYear() }} Velzon. Crafted with
                <i class="mdi mdi-heart text-danger"></i> by Themesbrand
              </p>
            </div>
          </BCol>
        </BRow>
      </BContainer>
    </footer>
  </div>
</template> -->