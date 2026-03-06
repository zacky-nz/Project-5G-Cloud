<script>
import animationData from "@/components/widgets/hzomhqxz.json";
import Lottie from "@/components/widgets/lottie.vue";

export default {
  data() {
    return {
      defaultOptions: {
        animationData: animationData
      },
    };
  },
  components: {
    lottie: Lottie
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
                                  <div class="p-lg-5 p-4 text-center">
                                      <lottie colors="primary:#405189,secondary:#08a88a" :options="defaultOptions"
                                          :height="180" :width="180" />

                                      <div class="mt-4 pt-2">
                                          <h5>You are Logged Out</h5>
                                          <p class="text-muted">Thank you for using <span
                                                  class="fw-semibold">Open Netra</span></p>
                                          <div class="mt-4">
                                              <router-link to="/auth/signin-basic" class="btn btn-secondary w-100">Sign
                                                  In</router-link>
                                          </div>
                                      </div>
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
                            <!-- <i class="mdi mdi-heart text-danger"></i> -->
                          </p>
                      </div>
                  </BCol>
              </BRow>
          </BContainer>
      </footer>
  </div>
</template>

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
                  <img src="@/assets/images/logo-light.png" alt="" height="20">
                </router-link>
              </div>
              <p class="mt-3 fs-15 fw-medium">Premium Admin & Dashboard Template</p>
            </div>
          </BCol>
        </BRow>

        <BRow class="justify-content-center">
          <BCol md="8" lg="6" xl="5">
            <BCard no-body class="mt-4">
              <BCardBody class="p-4 text-center">
                <lottie colors="primary:#405189,secondary:#08a88a" :options="defaultOptions" :height="180"
                  :width="180" />
                <div class="mt-4 pt-2">
                  <h5>You are Logged Out</h5>
                  <p class="text-muted">Thank you for using <span class="fw-semibold">Open Netra</span>
                    admin template</p>
                  <div class="mt-4">
                    <router-link to="/auth/signin-basic" class="btn btn-secondary w-100">Sign In
                    </router-link>
                  </div>
                </div>
              </BCardBody>
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
              <p class="mb-0 text-muted">&copy; {{ new Date().getFullYear() }} Velzon. Crafted with <i
                  class="mdi mdi-heart text-danger"></i> by Themesbrand</p>
            </div>
          </BCol>
        </BRow>
      </BContainer>
    </footer>
  </div>
</template> -->