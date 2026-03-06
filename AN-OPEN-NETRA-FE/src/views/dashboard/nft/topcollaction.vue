<script>
import { Swiper, SwiperSlide } from "swiper/vue";
import { Autoplay } from "swiper/modules";

import "swiper/css";
import "swiper/css/autoplay";

export default {
    data() {
        return {
            Autoplay
        };
    },
    components: {
        Swiper,
        SwiperSlide,
    }
};
</script>
<template>
    <BCard no-body>
        <BCardHeader class="d-flex align-items-center">
            <h6 class="card-title flex-grow-1 mb-0">Top Collections</h6>
            <router-link to="/apps/nft-collection" type="button" class="btn btn-soft-primary btn-sm flex-shrink-0">
                See All <i class="ri-arrow-right-line align-bottom"></i>
            </router-link>
        </BCardHeader>
        <BCardBody>
            <div class="swiper collection-slider">
                <div class="swiper-wrapper">
                    <swiper class="swiper responsive-swiper rounded gallery-light" :loop="true" :slidesPerView="1" :spaceBetween="10" :autoplay="{ delay: 2500, disableOnInteraction: false }" :modules="[Autoplay]">
                        <swiper-slide>
                            <div class="dash-collection overflow-hidden rounded-top position-relative">
                                <img src="@/assets/images/nft/img-03.jpg" alt="" height="220" class="object-fit-cover w-100" />
                                <div class="content position-absolute bottom-0 m-2 p-2 start-0 end-0 rounded d-flex align-items-center">
                                    <div class="flex-grow-1">
                                        <BLink href="#!">
                                            <h5 class="text-white fs-16 mb-1">Artworks</h5>
                                        </BLink>
                                        <p class="text-white text-opacity-75 mb-0">4700+ Items</p>
                                    </div>
                                    <div class="avatar-xxs">
                                        <div class="avatar-title bg-white rounded-circle">
                                            <BLink href="#!" class="link-success"><i class="ri-arrow-right-line"></i>
                                            </BLink>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="dash-collection overflow-hidden rounded-top position-relative">
                                <img src="@/assets/images/nft/img-04.jpg" alt="" height="220" class="object-fit-cover w-100" />
                                <div class="content position-absolute bottom-0 m-2 p-2 start-0 end-0 rounded d-flex align-items-center">
                                    <div class="flex-grow-1">
                                        <BLink href="#!">
                                            <h5 class="text-white fs-16 mb-1">Crypto Card</h5>
                                        </BLink>
                                        <p class="text-white text-opacity-75 mb-0">743+ Items</p>
                                    </div>
                                    <div class="avatar-xxs">
                                        <div class="avatar-title bg-white rounded-circle">
                                            <BLink href="#!" class="link-success"><i class="ri-arrow-right-line"></i>
                                            </BLink>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="dash-collection overflow-hidden rounded-top position-relative">
                                <img src="https://img.themesbrand.com/velzon/images/img-5.gif" alt="" height="220" class="object-fit-cover w-100" />
                                <div class="content position-absolute bottom-0 m-2 p-2 start-0 end-0 rounded d-flex align-items-center">
                                    <div class="flex-grow-1">
                                        <BLink href="#!">
                                            <h5 class="text-white fs-16 mb-1">3d Style</h5>
                                        </BLink>
                                        <p class="text-white text-opacity-75 mb-0">4781+ Items</p>
                                    </div>
                                    <div class="avatar-xxs">
                                        <div class="avatar-title bg-white rounded-circle">
                                            <BLink href="#!" class="link-success"><i class="ri-arrow-right-line"></i>
                                            </BLink>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="dash-collection overflow-hidden rounded-top position-relative">
                                <img src="@/assets/images/nft/img-06.jpg" alt="" height="220" class="object-fit-cover w-100" />
                                <div class="content position-absolute bottom-0 m-2 p-2 start-0 end-0 rounded d-flex align-items-center">
                                    <div class="flex-grow-1">
                                        <BLink href="#!">
                                            <h5 class="text-white fs-16 mb-1">Collectibles</h5>
                                        </BLink>
                                        <p class="text-white text-opacity-75 mb-0">3468+ Items</p>
                                    </div>
                                    <div class="avatar-xxs">
                                        <div class="avatar-title bg-white rounded-circle">
                                            <BLink href="#!" class="link-success"><i class="ri-arrow-right-line"></i>
                                            </BLink>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                    </swiper>
                </div>
            </div>
        </BCardBody>
    </BCard>
    <BCard no-body>
        <BCardHeader class="d-flex align-items-center">
            <h5 class="card-title flex-grow-1 mb-0">Popular Creators</h5>
            <router-link to="/apps/nft-creators" type="button" class="btn btn-soft-primary btn-sm flex-shrink-0">
                See All <i class="ri-arrow-right-line align-bottom"></i>
            </router-link>
        </BCardHeader>
        <BCardBody>
            <div class="swiper collection-slider">
                <div class="swiper-wrapper">
                    <swiper class="swiper responsive-swiper rounded gallery-light" :loop="true" :slidesPerView="1">
                        <swiper-slide>
                            <div class="d-flex">
                                <div class="flex-shrink-0">
                                    <img src="@/assets/images/nft/img-02.jpg" alt="" class="avatar-sm object-fit-cover rounded">
                                </div>
                                <div class="ms-3 flex-grow-1">
                                    <router-link to="/pages/profile">
                                        <h5 class="mb-1 fs-16">Alexis Clarke</h5>
                                    </router-link>
                                    <p class="text-muted mb-0"><i class="mdi mdi-ethereum text-primary fs-14"></i>
                                        81,369 ETH</p>
                                </div>
                                <div>
                                    <div class="dropdown float-end">
                                        <BDropdown variant="link" class="card-header-dropdown" dropstart toggle-class="text-reset dropdown-btn arrow-none" aria-haspopup="true">
                                            <template #button-content> <span class="text-muted fs-18"><i class="ri-more-fill align-middle fs-16"></i></span>
                                            </template>
                                            <BDropdownItem>View</BDropdownItem>
                                            <BDropdownItem>Share</BDropdownItem>
                                            <BDropdownItem>Report</BDropdownItem>
                                        </BDropdown>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="d-flex">
                                <div class="flex-shrink-0">
                                    <img src="@/assets/images/nft/img-01.jpg" alt="" class="avatar-sm object-fit-cover rounded">
                                </div>
                                <div class="ms-3 flex-grow-1">
                                    <router-link to="/pages/profile">
                                        <h5 class="mb-1 fs-16">Timothy Smith</h5>
                                    </router-link>
                                    <p class="text-muted mb-0"><i class="mdi mdi-ethereum text-primary fs-14"></i> 4,754
                                        ETH</p>
                                </div>
                                <div>
                                    <div class="dropdown float-end">
                                        <button class="btn btn-ghost-primary btn-icon dropdown" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="ri-more-fill align-middle fs-16"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">View</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">Share</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="#!">Report</BLink>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="d-flex">
                                <div class="flex-shrink-0">
                                    <img src="@/assets/images/nft/img-04.jpg" alt="" class="avatar-sm object-fit-cover rounded">
                                </div>
                                <div class="ms-3 flex-grow-1">
                                    <router-link to="/pages/profile">
                                        <h5 class="mb-1 fs-16">Herbert Stokes</h5>
                                    </router-link>
                                    <p class="text-muted mb-0"><i class="mdi mdi-ethereum text-primary fs-14"></i>
                                        68,945 ETH</p>
                                </div>
                                <div>
                                    <div class="dropdown float-end">
                                        <button class="btn btn-ghost-primary btn-icon dropdown" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="ri-more-fill align-middle fs-16"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">View</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">Share</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="#!">Report</BLink>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                        <swiper-slide>
                            <div class="d-flex">
                                <div class="flex-shrink-0">
                                    <img src="@/assets/images/users/avatar-1.jpg" alt="" class="avatar-sm object-fit-cover rounded">
                                </div>
                                <div class="ms-3 flex-grow-1">
                                    <router-link to="/pages/profile">
                                        <h5 class="mb-1 fs-16">Glen Matney</h5>
                                    </router-link>
                                    <p class="text-muted mb-0"><i class="mdi mdi-ethereum text-primary fs-14"></i>
                                        49,031 ETH</p>
                                </div>
                                <div>
                                    <div class="dropdown float-end">
                                        <button class="btn btn-ghost-primary btn-icon dropdown" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                            <i class="ri-more-fill align-middle fs-16"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end">
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">View</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="javascript:void(0);">Share</BLink>
                                            </li>
                                            <li>
                                                <BLink class="dropdown-item" href="#!">Report</BLink>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </swiper-slide>
                    </swiper>
                </div>
            </div>
        </BCardBody>
    </BCard>
</template>